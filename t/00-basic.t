use strict;
use warnings;

use Test::More;

plan tests => 6;

use_ok('Devel::MemoryTrace::Light', 'Module used');

my @tracked_mem;

sub track_mem {
	@tracked_mem = @_;
}

DB::set_callback(\&track_mem);

sub get_mem {
	my @temp = @tracked_mem;

	@tracked_mem = ();

	return @temp;
}

# Mock running under the debugger.
DB::DB(); my $string;
DB::DB(); $string = 'x' x (1024 * 1024 * 2);
DB::DB();

my @mem = get_mem();
is(@mem, 4,                      'Got memory change; callback worked');
is($mem[0],   'main',              'correct package');
is($mem[1],   't/00-basic.t',      'correct file');
is($mem[2],   '28',                'correct line');
like($mem[3], qr/^\d+$/,           'got bytes');
