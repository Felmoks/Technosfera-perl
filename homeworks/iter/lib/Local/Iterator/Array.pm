package Local::Iterator::Array;

use strict;
use warnings;
use Moose;
extends 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Array - array-based iterator

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Array->new(array => [1, 2, 3]);

=cut

has array => (
    traits => ['Array'],
    isa => 'ArrayRef',
    required => 1,
    handles => {
        _get   => 'get',
        _count => 'count',
    },
);

has _index => (
    traits => ['Counter'],
    is => 'ro',
    isa => 'Num',
    default => 0,
    init_arg => undef,
    handles => {
        _inc => 'inc'
    },
);

sub next {
    my ($self) = @_; 

    return (
        $self->_get($self->_index),
        $self->_count < $self->_inc,
    );
}

1;
