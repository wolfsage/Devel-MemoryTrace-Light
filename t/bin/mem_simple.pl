# Basic memory usage test case

my $string = '';

$string = 'x' x (1024 * 1024 * 2);

# So the previous line is considered before END time
print "hello world\n";
