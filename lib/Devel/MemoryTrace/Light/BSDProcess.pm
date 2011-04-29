package Devel::MemoryTrace::Light::BSDProcess;

use BSD::Process;

my $mem = BSD::Process->new();

sub get_mem {
	$mem->refresh;

	return $mem->rssize * 1024;
}

# We forked? Re-init
sub forked {
	$mem = BSD::Process->new();
}

1;


=pod

=head1 NAME

Devel::MemoryTrace::Light::BSDProcess - L<BSD::Process>

=head1 DESCRIPTION

Provides a L<BSD::Process> memory examiner to L<Devel::MemoryTrace::Light>

=cut
