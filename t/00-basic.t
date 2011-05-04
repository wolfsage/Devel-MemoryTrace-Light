use strict;
use warnings;

use Test::More;

plan tests => 4;

use Config;

my $perlbin;

eval "require Probe::Perl";

unless ($@) {
	$perlbin = Probe::Perl->find_perl_interpreter();
}

$perlbin ||= $Config{perlpath};

my $includes = '-I t/lib/';

# Simplest case
my $output = `$perlbin -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

like($output, qr/^>> \d+ main, .*mem_simple.pl \(5\) used \d+ bytes$/m,
	'4MB increase detected');

# Memory growth at end of program
$output = `$perlbin -d:MemoryTrace::Light t/bin/mem_at_end.pl 2>&1`;

like($output, qr/^>> \d+ main, .*mem_at_end.pl \(6\) used \d+ bytes$/m,
	'4MB increase detected');

# By default, compile-time is not traced
$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_at_compile_time.pl 2>&1`;

unlike($output, qr/>> \d+ DBMTraceMemIncAtCompile.*/,
	'compile-time tracing did not happen by default');

like($output, qr/hello world/m, 'program ran successfully');
