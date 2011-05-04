package DMTraceProviderExponential;

use strict;
use warnings;

my $x = 1;

sub get_mem {
	return $x *= 2;
}

1;
