# Make sure the last line in a program gets evaluated for mem growth at END 
# time

my $string;

$string = 'x' x (1024 * 1024 * 2);
