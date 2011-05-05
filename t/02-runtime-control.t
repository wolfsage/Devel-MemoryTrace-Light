use strict;
use warnings;

use Test::More;

plan tests => 9;

use Config;

my $perlbin;

eval "require Probe::Perl";

unless ($@) {
	$perlbin = Probe::Perl->find_perl_interpreter();
}

$perlbin ||= $Config{perlpath};

my $includes = '-I t/lib/';

# disable_trace/enable_trace
my $output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_disable_enable.pl 2>&1`;

unlike($output, qr/^>> \d+ main, .*mem_disable_enable.pl \(9\) used \d+ bytes$/m,
	'program was not traced with DB::disable_trace()');

like($output, qr/^>> \d+ main, .*mem_disable_enable.pl \(13\) used \d+ bytes$/m,
	'program still traced; increase detected');

like($output, qr/hello world/, 'program ran successfully');

# memory growth when tracing is disable gets ignored
$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_disable_enable_2.pl 2>&1`;

unlike($output, qr/^>> \d+ main, .*mem_disable_enable_2.pl \(9\) used \d+ bytes$/m,
	'program was not traced with DB::disable_trace()');

unlike($output, qr/^>> \d+ main, .*mem_disable_enable_2.pl \(15\) used \d+ bytes$/m,
	'program did not incorrectly report growth after enable_trace()');
like($output, qr/hello world/, 'program ran successfully');

# enable after start=no
$ENV{MEMORYTRACE_LIGHT} = 'start=no';

$output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_enable.pl 2>&1`;

unlike($output, qr/^>> \d+ main, .*mem_enable.pl \(6\) used \d+ bytes$/m,
	'program was not traced with start=no');

like($output, qr/^>> \d+ main, .*mem_enable.pl \(12\) used \d+ bytes$/m,
	'program traced after DB::enable_trace() after start=no; increase detected');

like($output, qr/hello world/, 'program ran successfully');

