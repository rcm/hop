use Iterator qw{imap igrep range};

my $it =igrep {$_ % 2 == 0}  imap {$_ * $_} range(1, 10);
tie *ZBR, 'Iterator', $it;

while(<ZBR>) {
	print;
	print "\n";
}
