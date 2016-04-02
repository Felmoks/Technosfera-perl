package Local::Iterator::Array;

use strict;
use warnings;
use parent 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Array - array-based iterator

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Array->new(array => [1, 2, 3]);

=cut

sub init {
    my ($self, %args) = @_;

    $self->{data} = [ @{ $args{array} } ];
}

sub next {
    my ($self) = @_; 

    my $end = (@{ $self->{data} } == 0);
    my $val = shift @{ $self->{data} };
    return ($val, $end);
}

1;
