package Local::TableRenderer;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(render_matrix);

my $nrows;
my $ncols;
my @widths;

my %shells = (
    header => {
        left        => '/',
        right       => "\\\n",
        separator   => '-',
    },

    footer => {
        left        => '\\',
        right       => "/\n",
        separator   => '-',
    },

    row_separator => {
        left        => '|',
        right       => "|\n",
        separator   => '+',
    },

    data_row => {
        left        => '|',
        right       => "|\n",
        separator   => '|',
    },

    cell => {
        left        => ' ',
        right       => ' ',
        placeholder => ' ',
    },

    border_cell => {
        left        => '-',
        right       => '-',
        placeholder => '-',
    },

);


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
    my $block = shift;
    my $shell = $block->{shell};
    my $data  = $block->{data};
    my $l     = $block->{len};
    
    my $left  = ref $shell->{left}  ? build_block($shell->{left})  : $shell->{left};
    my $right = ref $shell->{right} ? build_block($shell->{right}) : $shell->{right};

    my @print_data;

    if (defined $shell->{separator}) {
        my $separator = ref $shell->{separator} ? build_block($shell->{separator}) : $shell->{separator};
        my @subblocks = map { build_block($_) } @$data;

        local $" = $separator;
        local $, = '';

        return $left . "@subblocks" . $right;
    }
    else {
        my $p = $shell->{placeholder};

        my $padded_data = $p x ($l - length($data)) . $data;

        return $left . "$padded_data" . $right;
    }


}

sub render_matrix {
    my ($matrix) = @_;
    $nrows = @{ $matrix };
    $ncols = @{ $matrix->[0] };

    for my $i (0..$ncols-1) {
        $widths[$i] = max( map { length $_->[$i] } @$matrix );
    }

    my $super_matrix_data = [];

    for my $i (0..$nrows-1) {
        my $j = 0;
        my @row 
            = map { +{ shell => $shells{cell}, data => $_, len => $widths[$j++] } } @{ $matrix->[$i] };

        push @$super_matrix_data, { shell => $shells{data_row}, data => \@row, len => 1 }; 
    }

    my $super_matrix_shell = {
        left        => {
            shell => $shells{header},
            data  => [ map { +{shell => $shells{border_cell}, data=>"", len => $_ } } @widths ],
        },
        right       => {
            shell => $shells{footer},
            data  => [ map { +{shell => $shells{border_cell}, data=>"", len => $_ } } @widths ],
        },
        separator   => {
            shell => $shells{row_separator},
            data  => [ map { +{shell => $shells{border_cell}, data=>"", len => $_ } } @widths ],
        },
    };

    my $super_matrix = {
        shell => $super_matrix_shell,
        data  => $super_matrix_data,
    };

    my $str = build_block($super_matrix);

    print $str, "\n";
}

1;
