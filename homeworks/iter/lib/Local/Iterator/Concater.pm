package Local::Iterator::Concater;

use strict;
use warnings;
use parent 'Local::Iterator';

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

sub init {
    my ($self, %args) = @_;

    $self->{data} = [ @{ $args{iterators} } ];
    undef @{ $args{iterators} }; 
}

sub next {
    my ($self) = @_; 
    
    my ($val, $end) = $self->{data}[0]->next;

    return (undef, 1) if @{ $self->{data} } == 1 && $end;
    if ($end) {
        shift @{ $self->{data} };
        ($val, $end) = $self->{data}[0]->next;
    }

    return ($val, $end);

}


1;
