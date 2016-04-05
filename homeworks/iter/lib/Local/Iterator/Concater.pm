package Local::Iterator::Concater;

use strict;
use warnings;
use Moose; 

with 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Concater - concater of other iterators

=head1 SYNOPSIS

    my $iterator = Local::Iterator::Concater->new(
        iterators => [
            $another_iterator1,
            $another_iterator2,
        ],
    );

=cut

has iterators => (
    is => 'ro',
    isa => 'ArrayRef[ Local::Iterator ]',
    required => 1,
);

sub next {
    my ($self) = @_; 
    
    my ($val, $end) = $self->iterators->[0]->next;

    return (undef, 1) if @{ $self->iterators } == 1 && $end;
    if ($end) {
        shift @{ $self->iterators };
        ($val, $end) = $self->iterators->[0]->next;
    }

    return ($val, $end);

}


1;
