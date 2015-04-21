package Rewrite;
use strict;
use warnings;

use Data::Dumper;

use base 'Exporter';
our @EXPORT_OK = qw {create_rewriter};
our %EXPORT_TAGS = (
	'all' => [@EXPORT_OK]
);

sub compile_regexps {
	my ($re, $substitutions) = @_;

	for my $subs (keys %$substitutions) {
		$re =~ s/$subs/$substitutions->{$subs}/g;
	}
	$re;
}

sub preprocess_table {
	my ($table, $reg_subs) = @_;

	for my $re (keys %$table) {
		my $val = $table->{$re};
		delete $table->{$re};
		$table->{compile_regexps($re, $reg_subs)} = $val;
	}
}

sub create_rewriter {
	my ($table, %options) = @_;
	my $preprocess_line = $options{preprocess_line};

	preprocess_table($table, $options{preprocess_table}) if $options{preprocess_table};
	
	sub {
		my $line = shift;
		$line = $preprocess_line->($line) if defined $preprocess_line;
		my $old;
		do {
			$old = $line;
				
			for my $k (sort { $table->{$a}->[0] <=> $table->{$b}->[0] } keys %$table) {
				$line =~ s/$k/$table->{$k}[1]()/ge;
			}
		} while($old ne $line);
		$line;
	}
}

1
