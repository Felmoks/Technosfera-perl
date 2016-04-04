package Local::Iterator::Aggregator;

use strict;
use warnings;
use Moose;

extends 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Aggregator - aggregator of iterator

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Aggregator->new(
        chunk_length => 2,
        iterator => $another_iterator,
    );

=cut

has chunk_length => (
    is => 'ro',
    isa => 'Num',
    required => 1,
);

has iterator => (
    is => 'ro',
    isa => 'Local::Iterator',
    required => 1,
);

sub next {
    my ($self) = @_; 
    
    my @chunk;
    my ($val, $end) = $self->iterator->next;

    while (!$end ) {
        push @chunk, $val;
    } continue {
        last if @chunk == $self->chunk_length;
        ($val, $end) = $self->iterator->next;
    }

    return (@chunk > 0 ? \@chunk : undef, @chunk == 0);
}


1;
