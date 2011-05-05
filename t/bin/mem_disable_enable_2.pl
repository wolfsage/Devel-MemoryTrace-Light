# Ensure memory gained while tracing is disabled doesn't
# show up after enabled in strange places
use Devel::MemoryTrace::Light;

my $string = '';

DB::disable_trace();

$string = 'x' x (1024 * 1024 * 2);

$string = '';

DB::enable_trace();

print "hello world\n";

print "done\n";
