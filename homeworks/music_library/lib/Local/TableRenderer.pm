package Local::TableRenderer;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(render);

my $nrows;
my $ncols;
my @widths;

my %shells = (
    header => {
        left        => '/-',
        right       => "-\\\n",
        separator   => '---',
        placeholder => '-',
    },

    footer => {
        left        => '\\-',
        right       => "-/\n",
        separator   => '---',
        placeholder => '-',
    },

    row_separator => {
        left        => '|-',
        right       => "-|\n",
        separator   => '-+-',
        placeholder => '-',
    },

    data_row => {
        left        => '| ',
        right       => " |\n",
        separator   => ' | ',
    },

    cell => {
        left        => sub {},
        right       => sub {},
    },
);

$shells{table} = {
    left        => build_line($shells{header}),
    right       => build_line($shells{footer}),
    separator   => build_line($shells{row_separator}),
    subshell    => $shells{data_row},
};

sub pad {
    my ($row) = @_;

    my @padded_row
        = map { ' 'x($widths[$_]-length($row->[$_])) . $row->[$_] } 0..$ncols-1;

    return @padded_row;
}

sub separate {
   my ($row, $sep) = @_;

   my @separated_row = map { ($_, $sep) } @$row;
   pop @separated_row;

   return \@separated_row;
}

sub wrap {
    my ($row, $left, $right) = @_;

    my @wrapped_row = ($left, @$row, $right);

    return \@wrapped_row;
}

sub build_block {
    my $shell = shift;
    my @data;

    if (defined $shell->{placeholder}) {
        @data = map { $shell->{placeholder}x$widths[$_] } 0..$ncols-1; 
    }
    else {
        @data = pad(shift);
    }

	local $" = $shell->{separator};
	local $, = '';

    return $shell->{left} . "@data" . $shell->{right};
}

sub build_line {
    my $shell = shift;
    my $data  = shift;
    my $line;

    local *STDOUT;
    open STDOUT, '>', \$line;
    build_block($shell, $data);

    return $line;
}

sub render {
    my ($matrix) = @_;
    $nrows = @{ $matrix };
    $ncols = @{ $matrix->[0] };

    for my $i (0..$ncols-1) {
        $widths[$i] = max( map { length $_->[$i] } @$matrix );
    }

    my $row_separator = build_line($shells{row_separator});

    #    build_block($shells{table});
    #
    #    {
    #        local $" = $row_separator;
    #        local $, = '';
    #
    #        my @rows = map { build_line($shells{data_row}, $_) } @$matrix;
    #
    #        print "@rows";
    #    }
    #
    #    build_block($shells{footer});


    print join ' ', @widths , "\n";
   
    print $nrows, ' ', $ncols, "\n";
}

1;
