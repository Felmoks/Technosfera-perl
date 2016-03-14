package Local::BlockRenderer;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(render_block);

sub render_block {
    my $block  = shift;

    return $block if !ref $block;

    my $shell  = $block->{shell};
    my $data   = $block->{data};
    my $widths = $block->{widths};
    my $pad    = $block->{pad};

    my $left        = render_block($shell->{left});
    my $right       = render_block($shell->{right});
    my $placeholder = render_block($shell->{placeholder});
    my $separator   = render_block($shell->{separator});

    my @subblocks = map { render_block($_) } @$data;

    @subblocks = map { $pad->($placeholder, $widths->[$_], $subblocks[$_]) } 0..$#subblocks;

    return $left . join($separator, @subblocks) . $right;
}

1;
