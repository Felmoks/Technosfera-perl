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


sub pad_left {
    my ($ph, $len, $data, $data_length) = @_;
    return $ph x ($len - $data_length->($data)) . $data;
}

sub pad_right {
    my ($ph, $len, $data, $data_length) = @_;
    return  $data . $ph x ($len - $data_length->($data));
}

sub pad_center {
    my ($ph, $len, $data, $data_length) = @_;
    my $pad_length = $len - $data_length->($data);
    my $left  = int($pad_length / 2);
    my $right = $pad_length - $left;
    return $ph x $left . $data . $ph x $right;
}


my $strlen = sub { length($_[0]) };
my $pad_cell_left  = sub { pad_left($_[0], $_[1], $_[2], $strlen) };

my $rowlen = sub { ($_[0] =~ tr/\n//) };
my $pad_row_center = sub { pad_center($_[0], $_[1], $_[2], $rowlen) };


sub shell_row {
    my ($row_type, $widths) = @_;
    return {
        shell  => $shells{$row_type},
        data   => [ map { "" } @$widths ],
        widths => $widths,
        pad    => $pad_cell_left,
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
            shell  => $shells{data_row},
            data   => \@row,
            widths => \@widths,
            pad    => $pad_cell_left,
        }; 
    }

    my $block_shell = {
        left        => shell_row('header', \@widths),
        right       => shell_row('footer', \@widths),
        separator   => shell_row('row_separator', \@widths),
        placeholder => shell_row('data_row', \@widths),
    };

    my $block = {
        shell  => $block_shell,
        data   => $block_data,
        widths => [ (1)x$nrows ],
        pad    => $pad_row_center,
    };

    return $block;
}

1;
