# Basic disable/enable test

use Devel::MemoryTrace::Light;

my $string = '';

DB::disable_trace();

$string = 'x' x (1024 * 1024 * 2);

DB::enable_trace();

$string = 'x' x (1024 * 1024 * 2);

print "hello world\n";
