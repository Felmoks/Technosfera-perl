package Local::BlockRenderer;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(render_block);

sub pad_cell_left {
    my ($ph, $len, $data) = @_;
    return $ph x ($len - length($data)) . $data;
}

sub pad_cell_right {
    my ($ph, $len, $data) = @_;
    return  $data . $ph x ($len - length($data));
}

sub pad_cell_center {
    my ($ph, $len, $data) = @_;
    my $pad_length = $len - length($data);
    my $left  = int($pad_length / 2);
    my $right = $pad_length - $left;
    return $ph x $left . $data . $ph x $right;
}

sub render_block {
    my $block  = shift;
    my $shell  = $block->{shell};
    my $data   = $block->{data};
    my $widths = $block->{widths};

    return $data if !defined $shell;

    my $len   = $block->{len};
    
    my $left  = ref $shell->{left}  ? render_block($shell->{left})  : $shell->{left};
    my $right = ref $shell->{right} ? render_block($shell->{right}) : $shell->{right};
    my $ph    = ref $shell->{placeholder} ? render_block($shell->{placeholder}) : $shell->{placeholder};

    my $separator = ref $shell->{separator} ? render_block($shell->{separator}) : $shell->{separator};
    my @subblocks = map { render_block($_) } @$data;

    @subblocks = map { pad_cell_left($ph, $widths->[$_], $subblocks[$_]) } 0..@subblocks-1;

    local $" = $separator;

    return $left . "@subblocks" . $right;
}

1;
