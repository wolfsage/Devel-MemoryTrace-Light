package Devel::MemoryTrace::Light;

BEGIN {
	$Devel::MemoryTrace::Light::VERSION = '0.04';
}

use strict;
use warnings;

my $mem_class;

if (my $opts = $ENV{MEMORYTRACE_LIGHT}) {
	for my $opt (split(':', $opts)) {
		my ($key, $val) = split('=', $opt);

		if ($key eq 'start') {
			if ($val eq 'no') {
				&DB::disable_trace;
			} else {
				warn "Ignoring unknown value $val for 'start'\n";
			}
		} elsif ($key eq 'provider') {
			eval "use $val";

			die "Failed to load custom provider ($val): $@\n" if $@;

			die "Custom provider ($val) doesn't provide a get_mem() method!\n"
				unless $val->can('get_mem');

			die "Custom provider ($val\::get_mem()) doesn't return an integer value\n"
				unless $val->get_mem() =~ /\A\d+\Z/;

			$mem_class = $val;
		} else {
			warn "Ignoring unknown config $key\n";
		}
	}
}

unless ($mem_class) {
	my @mod_preference = qw(
		Devel::MemoryTrace::Light::BSDProcess
		Devel::MemoryTrace::Light::GTop
	);

	if ($^O ne 'freebsd') {
		shift @mod_preference;
	}

	for my $p (@mod_preference) {
		eval "use $p";

		unless ($@) {
			$mem_class = $p; last;
		}
	}

	unless ($mem_class) {
		die "No suitable memory examiner found!\n";
	}
}

package DB;

use strict;
use warnings;

my $trace = 1;

my $callback = \&_report;

my $last_mem = $mem_class->get_mem();
my @last_id  = ('init', 0, 0);

my $pid = $$;

sub set_callback (&) {
	$callback = $_[0];
}

sub restore_callback () {
	$callback = \&_report;
}

sub enable_trace () {
	# Memory tracing has been disabled, update our state
	if ($pid != $$) {
		$mem_class->forked() if $mem_class->can('forked');

		$pid = $$;
	}

	$last_mem = $mem_class->get_mem();
	@last_id = caller();

	$trace = 1;
}

sub disable_trace () {
	$trace = 0;
}

sub _report {
	my ($pkg, $file, $line, $mem) = @_;

	printf(">> $$ $pkg, $file ($line) used %d bytes\n", $mem);
}

sub DB {
	return unless $trace;

	if ($pid != $$) {
		$mem_class->forked() if $mem_class->can('forked');

		$pid = $$;
	}

	my $newmem = $mem_class->get_mem();

	if ($newmem > $last_mem) {
		$callback->(@last_id, $newmem - $last_mem);

		$last_mem = $newmem;
	}

	@last_id = caller();
}

END {
	DB::DB(); # Force last line to be evaluated for memory growth

	disable_trace(); # Otherwise we'll probably crash
}

1;


# ABSTRACT: A simple lightweight memory-growth tracer

=pod

=head1 NAME

Devel::MemoryTrace::Light - Print a message when your program grows in memory

=head1 VERSION

version .04

=head1 SYNOPSIS

  perl -d:MemoryTrace::Light Program

=head1 DESCRIPTION

B<This is an Alpha release! More features to come.>

Prints out a message when your program grows in memory containing the 
B<pid>, B<package>, B<file>, B<line>, and B<number of bytes> (resident set 
size) your program increased. For example, if your program looked like this:

  #!/usr/bin/perl

  use strict;
  use warnings;

  my @arr;
  $arr[4096] = 'hello';

Then the output will look like:

  >> 324 init, 0 (0) used 8192 bytes
  >> 324 main, ex.pl (7) used 20480 bytes

=head1 MEMORYTRACE_LIGHT ENVIRONMENT VARIABLE

The C<MEMORYTRACE_LIGHT> environment variable may be used to control some of the 
behaviors of Devel::MemoryTrace::Light. The format is C<key=value>, and multiple 
values may be set at one time using the C<:> separator. For example:

  export MEMORYTRACE_LIGHT=start=no:provider=MyClass

=head2 provider=...

Forces Devel::MemoryTrace::Light to use whatever class is passed in to determine 
memory usage.

The provider class I<must> define a C<get_mem()> method which should return 
the current process' memory size. The built in modules return the resident set 
size, but a custom provider could use virtual, swap, or whatever it wants, as 
long as it returns the same type of information consistently.

The provider class I<should> also define a C<forked()> method which will be 
called if Devel::MemoryTrace::Light detects that the process has forked. This method 
should do any re-initialization necessary for the provider class to accurately 
report memory for the new forked process.

The B<provider> setting may also be used to force Devel::MemoryTrace::Light to 
prefer one of the built-in providers over another if more than one is installed.

=head2 start=no

You may disable tracing automatically by setting C<start=no>. This allows you to 
later enable tracing by calling C<DB::enable_trace()>. See below for more 
information.

=head1 RUN-TIME CONTROL OF TRACING

A limited set of functionality is provided for run-time control of tracing.

=head2 DB::disable_trace()

=head2 DB::enable_trace()

You can control when tracing happens by using C<DB::enable_trace()> and 
C<DB::disable_trace>. This works well coupled with the C<start=no> 
setting in the C<MEMORYTRACE_LIGHT> environment variable described above.

=head2 DB::set_callback(\&somefunc)

If you would like to override the default behavior of printing to STDOUT 
whenever the program size increases, you may provide your own callback method.

This causes C<\&somefunc> to be called whenever the debugger detects an increase 
in memory size. C<\&somefunc> should accept 4 arguments:

=over 4

=item * $pkg

=item * $file

=item * $line

=item * $bytes

=back

=head2 DB::restore_callback()

Restores the default callback.

=head1 OS SUPPORT

Currently works on FreeBSD, Linux, and anywhere else L<GTop> is supported.

On FreeBSD, installing this module will install L<BSD::Process> unless
L<GTop> is already installed. L<BSD::Process> will be preferred if both
modules are on the system.

=head1 BUGS

Please report any bugs (or feature requests) through L<http://rt.cpan.org/>.

=head1 AUTHOR

Matthew Horsfall (alh) - <WolfSage@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Matthew Horsfall.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
