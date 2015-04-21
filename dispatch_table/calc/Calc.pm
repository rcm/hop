package Calc;
use base 'Exporter';
@EXPORT_OK = qw {create_calculator};

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

sub create_calculator {
	my $id = qr/[A-Za-z]\w*/;
	my $opt_spc = qr/\s*/;
	my $number = qr/(\d+)|\((-\d+)\)/;
	my $optable = {
		'+' => sub { $_[0] + $_[1] },
		'-' => sub { $_[0] - $_[1] },
		'*' => sub { $_[0] * $_[1] },
		'/' => sub { $_[0] / $_[1] },
		'%' => sub { $_[0] % $_[1] },
		'**' => sub { $_[0] ** $_[1] },
		'//' => sub { int($_[0] / $_[1]) },
	};

	# Adding a bunch of functions by name
	for my $f (qw(mdc mmc min max)) {
		$optable->{$f} = eval{\&$f};
	}
	
	my $binding = {};
	
	my $table = {
		q{([A-Za-z]\w*?)\((.*?)\)} => [1, sub { exists $optable->{$1} ? $optable->{$1}->(split /\s*,\s*/, $2) : $& }],
		q{\( (\d+) \)}			=> [1, sub { $1 }],
		q{(\d+)\!}					=> [2, sub { my $p = 1; my $x = $1; $p *= $x-- while($x > 0); $p }],
		qq{$number (\\*\\*|//) $number}	=> [3, sub { $optable->{$3}->("$1$2", "$4$5") }],
		qq{$number ([*/%]) $number}	=> [4, sub { $optable->{$3}->("$1$2", "$4$5") }],
		qq{$number ([+-]) $number}	=> [5, sub { $optable->{$3}->("$1$2", "$4$5") }],
		q{($id) = (-?\d+)}		=> [6, sub { $binding->{$1} = $2; return $& }],
		qq{\\\$($id)}					=> [7, sub { exists $binding->{$1} ? $binding->{$1} : $& }]
	};

	sub {
		my $line = shift;
		my $old;
		$line =~ s/\s+/ /g;
		do {
			$old = $line;
				
			for my $k (sort { $table->{$a}->[0] <=> $table->{$b}->[0] } keys %$table) {
				$qk = join("$opt_spc", split(/ /, $k));
				$line =~ s/$qk/$table->{$k}[1]()/ge;
			}
		} while($old ne $line);
		$line;
	}
}

1
