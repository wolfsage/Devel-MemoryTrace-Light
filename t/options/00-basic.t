use strict;
use warnings;

use Test::More;

plan tests => 2;

use Config;

my $perlbin;

eval "require Probe::Perl";

unless ($@) {
	$perlbin = Probe::Perl->find_perl_interpreter();
}

$perlbin ||= $Config{perlpath};

my $includes = '-I t/lib/';

# Bad option
$ENV{MEMORYTRACE_LIGHT} = 'fake=option:provider=DMTraceProviderNextMem';

my $output = `$perlbin $includes -d:MemoryTrace::Light t/bin/mem_simple.pl 2>&1`;

like($output, qr/^Ignoring unknown config option \(fake\)$/m,
	'bad ENV option detected');

like($output, qr/^>> \d+ main, .*mem_simple.pl \(6\) used 1024 bytes$/m,
	'program still traced; increase detected');
