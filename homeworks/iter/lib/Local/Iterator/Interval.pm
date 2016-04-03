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

sub _earliest {
    my ($dt1, $dt2) = @_;

    my $cmp = DateTime->compare($dt1, $dt2);

    return $cmp < 0 ? $dt1->clone : $dt2->clone;
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

    $to = _earliest($next_to, $self->{to});

    $self->{from} = _earliest($next_from, $self->{to});
    
    my $ret = Local::Interval->new(
        from => $from,
        to   => $to,
    );

    return $ret;
}
    
1;
