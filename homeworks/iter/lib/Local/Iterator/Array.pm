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

    $self->{data}  = $args{array};
    $self->{index} = 0;
}

sub next {
    my ($self) = @_; 

    return (
        $self->{data}[$self->{index}++],
        @{ $self->{data} } < $self->{index},
    );
}

1;
