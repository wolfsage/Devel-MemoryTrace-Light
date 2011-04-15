package Devel::MemoryTrace::Light;

BEGIN {
	$Devel::MemoryTrace::Light::VERSION = '0.03';
}

use strict;
use warnings;

my @mod_preference = qw(
	Devel::MemoryTrace::Light::BSDProcess
	Devel::MemoryTrace::Light::GTop
);

if ($^O ne 'freebsd') {
	shift @mod_preference;
}

my $mem_class;

for my $p (@mod_preference) {
	eval "use $p";

	unless ($@) {
		$mem_class = $p; last;
	}
}

unless ($mem_class) {
	die "No suitable memory examiner found!\n";
}


package DB;

use strict;
use warnings;

my $trace = 1;

my $callback = \&_report;

sub set_callback (&) {
	$callback = $_[0];
}

sub restore_callback () {
	$callback = \&_report;
}

sub _disable_trace {
	$trace = 0;
}

sub _report {
	my ($pkg, $file, $line, $mem) = @_;

	printf(">> $pkg, $file ($line) used %d bytes\n", $mem);
}

my $last_mem = $mem_class->get_mem();
my @last_id  = ('init', 0, 0);

sub DB {
	return unless $trace;

	my $newmem = $mem_class->get_mem();

	if ($newmem > $last_mem) {
		$callback->(@last_id, $newmem - $last_mem);

		$last_mem = $newmem;
	}

	@last_id = caller();
}

END {
	DB::DB(); # Force last line to be evaluated for memory growth

	_disable_trace();	
}

1;


# ABSTRACT: A simple lightweight memory-growth tracer

=pod

=head1 NAME

Devel::MemoryTrace::Light - Print a message when your program grows in memory

=head1 VERSION

version .03

=head1 SYNOPSIS

  perl -d:MemoryTrace::Light Program

=head1 DESCRIPTION

B<This is an Alpha release! More features to come.>

Prints out a message when your program grows in memory containing the package, 
file, line, and number of bytes (resident set size) your program increased. For 
example, if your program looked like this:

  #!/usr/bin/perl

  use strict;
  use warnings;

  my @arr;
  $arr[4096] = 'hello';

Then the output will look like:

  >> init, 0 (0) used 8192 bytes
  >> main, ex.pl (7) used 20480 bytes

=head1 RUN-TIME CONTROL OF TRACING

If you would like to override the default behavior of printing to STDOUT 
whenever the program size increases, you may provide your own callback method.

=head2 set_callback(\&somefunc)

Causes C<\&somefunc> to be called whenever the debugger detects an increase in 
memory size. C<\&somefunc> should accept 4 arguments:

=over 4

=item * $pkg

=item * $file

=item * $line

=item * $bytes

=back

=head2 restore_callback()

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
