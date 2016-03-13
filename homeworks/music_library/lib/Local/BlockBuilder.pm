package Local::BlockBuilder;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(build_block);

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
        placeholder => ' ',
    },
);

sub shell_row {
    my ($row_type, $cell_type, $widths) = @_;
    return {
        shell  => $shells{$row_type},
        data   => [ map { "" } @$widths ],
        widths => $widths,
    };
}

sub build_block {
    my ($matrix) = @_;
    my $nrows = @{ $matrix };
    my $ncols = @{ $matrix->[0] };
    my @widths;

    for my $i (0..$ncols-1) {
        $widths[$i] = max( map { length $_->[$i] } @$matrix );
    }

    my $block_data = [];

    for my $i (0..$nrows-1) {
        my @row = map { $matrix->[$i][$_] } 0..$ncols-1;

        push @$block_data, {
            shell => $shells{data_row},
            data => \@row,
            widths => \@widths,
        }; 
    }

    my $block_shell = {
        left        => shell_row('header', 'border_cell', \@widths),
        right       => shell_row('footer', 'border_cell', \@widths),
        separator   => shell_row('row_separator', 'border_cell', \@widths),
        placeholder => shell_row('data_row', 'cell', \@widths),
    };

    my $block = {
        shell  => $block_shell,
        data   => $block_data,
        widths => [ (1)x$nrows ],
    };

    return $block;
}

1;
