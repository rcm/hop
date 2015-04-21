package Iterator;
use Exporter 'import';
@EXPORT_OK = qw(imap igrep range);

sub Iterator (&) {
	return shift;
}

sub range {
	my ($from, $to) = @_;

	return Iterator {
		return $from++ unless defined $to and $from > $to;
		return;
	};
}

sub imap(&$) {
	my ($func, $iterator) = @_;

	return sub {
		local $_ = $iterator->();
		return unless defined $_;
		return $func->();
	};
}

sub igrep(&$) {
	my ($func, $iterator) = @_;

	return sub {
		local $_;
		
		while(defined ($_ = $iterator->())) {
			return $_ if $func->();
		}
		return;
	};
}

sub TIEHANDLE {
	my ($package, $iterator) = @_;
	return bless {ITERATOR => $iterator}, $package;
}

sub READLINE {
	my ($self) = @_;
	return $self->{ITERATOR}->();
}
1;
