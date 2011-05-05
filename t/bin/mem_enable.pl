# Memory tracing enabled after start=no
use Devel::MemoryTrace::Light;

my $string = '';

$string = 'x' x (1024 * 1024 * 2);

$string = '';

DB::enable_trace();

$string = 'x' x (1024 * 1024 * 2);

print "hello world\n";

