use Rewrite ':all';

sub mdc {
	my ($x, $y, @r) = @_;
	while($y != 0) {
		($x, $y) = ($y, $x % $y);
	}
	@r ? mdc($x, @r) : $x;
}

sub mmc {
	my ($x, $y, @r) = @_;

	$x = $x * $y / mdc($x, $y);
	@r ? mmc($x, @r) : $x;
}

sub fold {
	my $fun = shift;

	sub {
		my $r = shift;
		for(@_) {
			$r = $fun->($r, $_);
		}
		$r
	}
}

*min = fold sub {$_[0] < $_[1] ? $_[0] : $_[1]};
*max = fold sub {$_[0] > $_[1] ? $_[0] : $_[1]};

my $optable = {
	'//' => sub { int($_[0] / $_[1]) },
};

for my $f (qw(+ - * / % **)) {
	$optable->{$f} = eval sprintf 'sub { $_[0] %s $_[1] }', $f;
	print "$@\n" if $@;
}

# Adding a bunch of functions by name
for my $f (qw(mdc mmc min max)) {
	$optable->{$f} = eval{\&$f};
}

my $binding = {};
my $table = {
	q{zero} => [1, '0'],
	q{boo} => [1, 'foo'],
	q{inv \( NUMBER \)}                => [1, '1/($1)'],
    q{\$(ID)}                          => [1, sub { exists $binding->{$1} ? $binding->{$1} : $& }],
    q{(ID)\((NUMBER(?: , NUMBER)*)\)}  => [2, sub { exists $optable->{$1} ? $optable->{$1}->(split /\s*,\s*/, $2) : $& }],
    q{\( (NUMBER) \)}                  => [2, sub { $1 }],
    q{(\d+)\!}                         => [3, sub { my $p = 1; my $x = $1; $p *= $x-- while($x > 0); $p }],
    q{NUMBER (\*\*|//) NUMBER}         => [4, sub { $optable->{$2}->($1, $3) }],
    q{NUMBER ([*/%]) NUMBER}           => [5, sub { $optable->{$2}->($1, $3) }],
    q{NUMBER ([+-]) NUMBER}            => [6, sub { $optable->{$2}->($1, $3) }],
    q{(ID) = (NUMBER)}                 => [7, sub { $binding->{$1} = $2; return $& }],
};

my $prep = {
	NUMBER  => '(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)',
	ID      => '[A-Za-z]\w*',
	' '     => '\s*'
};

my $it = 1;
*prompt = sub {
	printf "[%d]> ", $it;
	$_ = <>;
};

my $rw = create_rewriter($table, preprocess_line => sub { sprintf "Result[%d] => %s", $it++, $_[0] }, preprocess_table => $prep);

while(prompt()) {
	$rw->();
	print;
}
