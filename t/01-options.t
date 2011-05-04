use strict;
use warnings;

use Test::More;

#plan tests => 10;

use Config;

my $perlbin;

eval "require Probe::Perl";

unless ($@) {
	$perlbin = Probe::Perl->find_perl_interpreter();
}

$perlbin ||= $Config{perlpath};

my $includes = '-I t/lib/';

# Bad option
$ENV{MEMORYTRACE_LIGHT} = 'fake=option';

my $output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

like($output, qr/^Ignoring unknown config option \(fake\)$/m,
	'bad ENV option detected');

like($output, qr/^>> \d+ main, .*mem_simple.pl \(5\) used \d+ bytes$/m,
	'program still traced; 4MB increase detected');


# Bad 'start'
$ENV{MEMORYTRACE_LIGHT} = 'start=fake';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

like($output, qr/^Ignoring unknown value \(fake\) for 'start'\n/m,
	'bad ENV value for start detected');

like($output, qr/^>> \d+ main, .*mem_simple.pl \(5\) used \d+ bytes$/m,
	'program still traced; 4MB increase detected');

# Bad 'provider' (not found)
$ENV{MEMORYTRACE_LIGHT} = 'provider=NoSuChModUleExisTs';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

like($output, qr/^Custom provider \(NoSuChModUleExisTs\) failed to load:.*$/m,
	'bad ENV value for provider detected');

unlike($output, qr/^>> \d+ main, .*mem_simple.pl \(5\) used \d+ bytes$/m,
	'program died without tracing');

# Bad 'provider' (get_mem() missing)
$ENV{MEMORYTRACE_LIGHT} = 'provider=DMTraceBadProviderNoGetMem';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

like($output, qr/^Custom provider \(DMTraceBadProviderNoGetMem\) failed to load: No get_mem\(\) method found$/m,
	'bad ENV value for provider detected');

unlike($output, qr/^>> \d+ main, .*mem_simple.pl \(5\) used \d+ bytes$/m,
	'program died without tracing');

# Bad 'provider' (didn't return an integer)
$ENV{MEMORYTRACE_LIGHT} = 'provider=DMTraceBadProviderGetMemReturnsBadData';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

like($output, qr/^Custom provider \(DMTraceBadProviderGetMemReturnsBadData\) failed to load: get_mem\(\) didn't return an integer$/m,
	'bad ENV value for provider detected');

unlike($output, qr/^>> \d+ main, .*mem_simple.pl \(5\) used \d+ bytes$/m,
	'program died without tracing');

# Good 'start' = 'no'
$ENV{MEMORYTRACE_LIGHT} = 'start=no';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

unlike($output, qr/^>> \d+ main, .*mem_simple.pl \(5\) used \d+ bytes$/m,
	'program not traced with start=no');

like($output, qr/hello world/m, 'program ran successfuly');

# Good 'start' = 'begin'
$ENV{MEMORYTRACE_LIGHT} = 'start=begin';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_at_compile_time.pl 2>&1`;

like($output, qr/^>> \d+ DMTraceMemIncAtCompile, .*DMTraceMemIncAtCompile.pm \(8\) used \d+ bytes$/m,
	'program traced at compile-time with start=begin');

like($output, qr/hello world/m, 'program ran successfuly');

# Good provider
$ENV{MEMORYTRACE_LIGHT} = 'provider=DMTraceProviderExponential';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/test_provider.pl 2>&1`;

my $expect = 4;

# Incase 'init' isn't detected somehow
if ($output =~ /init/) {
	$expect *= 2;
}

like($output, qr/>> \d+ main, .*test_provider.pl \(3\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(5\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

# For 1..10 ... 
like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(6\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/>> \d+ main, .*test_provider.pl \(9\) used $expect bytes$/m,
	'memory incremented as expected');
$expect *= 2;

like($output, qr/hello world/m, 'program ran successfuly');

done_testing;
