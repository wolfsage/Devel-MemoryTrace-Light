package Devel::MemoryTrace::Light::GTop;

use GTop;

my $gtop = GTop->new();

sub get_mem {
	return $gtop->proc_mem($$)->resident;
}

# We forked? Re-init
sub forked {
	$gtop = GTop->new();
}

1;


=pod

=head1 NAME

Devel::MemoryTrace::Light::GTop - L<GTop>

=head1 DESCRIPTION

Provides a L<GTop> memory examiner to L<Devel::MemoryTrace::Light>

=cut
