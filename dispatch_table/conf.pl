use Carp;
sub conf  ($\%) {
	my ($file, $table) = @_;
	my $fh;

	open $fh, $file or return;
	
	while(<$fh>) {
		chomp;
		my ($field, $value) = split /\s+/, $_, 2;
		if(defined $table->{$field}) {
			$table->{$field}($value, $table);
		} else {
			warn "Warning: Invalid option $field. Aborting.\n";
			return 0;
		}
	}
	return 1;
}

sub define_new_concept {
	my ($definition, $table) = @_;

	my ($name, $rest) = split /\s+/, $definition, 2;

	warn "Warning: redefined $name concept\n" if defined $table->{$name};
	$table->{$name} = eval "sub { $rest }";
}

my %tab = (
	A => sub { $a = $_[0] },
	DEFINE => \&define_new_concept,
	INCLUDE => \&conf
);

conf(shift, %tab);
print "depois: $a\n";
