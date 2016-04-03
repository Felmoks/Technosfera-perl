package Local::Iterator::Interval;

use strict;
use warnings;
use DateTime;
use DateTime::Duration;
use Local::Interval;
use Data::Dumper;
use parent 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::Interval - interval iterator

=head1 SYNOPSIS

    use DateTime;
    use DateTime::Duration;

    my $iterator = Local::Iterator::Interval->new(
      from   => DateTime->new('...'),
      to     => DateTime->new('...'),
      step   => DateTime::Duration->new(seconds => 25),
      length => DateTime::Duration->new(seconds => 35),
    );

=cut

sub init {
    my ($self, %args) = @_;    

    %$self = %args;
    $self->{length} = $self->{step} if !defined($self->{length});
}

sub next {
    my ($self) = @_;

    my $left = $self->{to}->subtract_datetime($self->{from});
    
    return (undef, 1)
        if DateTime::Duration->compare($left, $self->{length}, $self->{from}) < 0;

    my $from = $self->{from}->clone;
    my $to;

    my $next_to   = $self->{from}->clone;
    $next_to->add_duration($self->{length}); 

    my $next_from = $self->{from}->clone;
    $next_from->add_duration($self->{step});

    if (DateTime->compare($self->{to}, $next_to) > 0) {
        $to = $next_to; 
    }
    else {
        $to = $self->{to}->clone;
    }

    if (DateTime->compare($self->{to}, $next_from) > 0) {
        $self->{from} = $next_from; 
    }
    else {
        $self->{from} = $self->{to}->clone;
    }
    
    my $ret = Local::Interval->new(
        from => $from,
        to   => $to,
    );

    return $ret;
}
    
1;
