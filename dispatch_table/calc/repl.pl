{
	my $cnt = 1;
	sub prompt {
		print "\n$cnt> ";
		$cnt++;
	}
}

prompt();
while(<>) {
	print eval($_) unless $@;
	print $@ if $@;
	undef $@;
	prompt();
}
