package Stream;
use base Exporter;

our @EXPORT_OK = qw (node head tail promise is_promise transform filter iterate take drop take_while drop_while list_to_stream cut_sort range show);
our %EXPORT_TAGS = (
	all => [@EXPORT_OK]
);

sub node {
	my ($h, $t) = @_;
	[$h, $t];
}

sub head {
	shift->[0];
}

sub tail {
	if(is_promise($_[0]->[1])) {
		return $_[0]->[1] = $_[0]->[1]();
	}
	return $_[0]->[1];
}

sub promise(&) {
	return shift;
}

sub is_promise {
	UNIVERSAL::isa($_[0], 'CODE');
}

sub transform (&$) {
	my ($f, $s) = @_;

	return unless $s;
	return node($f->(head($s)), promise { transform($f, tail($s)) });
}

sub filter (&$) {
	my ($f, $s) = @_;

	while($s) {
		my $val = head($s);
		return node($val, promise { filter($f, tail($s))}) if $f->($val);
		$s = tail($s);
	}
}

sub iterate (&$) {
	my ($f, $x) = @_;

	node($x, promise { iterate($f, $f->($x)) });
}

sub range {
	my ($from, $to) = @_;

	return if defined $to && $to < $from;
	return node($from, promise { range($from + 1, $to) });
}

sub take ($$) {
	my ($n, $s) = @_;

	return unless $n > 0;

	node(head($s), promise { take($n - 1, tail($s)) } )
}

sub drop ($$) {
	my ($n, $s) = @_;

	return $s unless $n > 0;

	$s = tail($s), $n-- while($s && $n);
	return $s;
}

sub take_while (&$) {
	my ($f, $s) = @_;

	return unless $f->(head($s));

	node(head($s), promise { take_while($f, tail($s)) });
}

sub drop_while (&$) {
	my ($f, $s) = @_;

	$s = tail($s) while $f->(head($s));
	return $s;
}

sub insert ($$\@) {
	my ($x, $func, $lst) = @_;

	my ($lo, $hi) = (0, scalar(@$lst));

	while($lo < $hi) {
		my $m = int(($lo + $hi) / 2);
		if($func->($lst->[$m], $x) < 0) {
			$lo = $m + 1;
		} else {
			$hi = $m;
		}
	}
	splice @$lst, $lo, 0, $x;
}


sub list_to_stream {
	my $node = pop;
	$node = node(pop, $node) while(@_);
	$node;
}

sub cut_sort {
	my ($s, $order_func, $cut_func, @pending) = @_;

	return unless $s;

	while($s) {
		my $val = head($s);
		my @emit;

		while(@pending && $cut_func->($pending[0], $val)) {
			push @emit, shift @pending;
		}
		
		insert($val, $order_func, @pending);

		return list_to_stream(@emit, promise { cut_sort(tail($s), $order_func, $cut_func, @pending) }) if @emit;
		$s = tail($s);
	}
	return list_to_stream(@pending);
}

sub show {
	my ($s, $n, $f) = @_;

	while($s) {
		last if defined $n && $n-- == 0;
		my $val = head($s);
		$val = $f->($val) if defined $f;
		print $val, $";
		$s = tail($s);
	}
	print $/;
}

1
