package Local::Interval;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Interval - time interval

=head1 SYNOPSIS

    my $interval = Local::Interval->new('...');

    $interval->from(); # DateTime
    $interval->to(); # DateTime

=cut

sub new {
    my ($class, %args) = @_;

    return bless \%args, $class;
}

sub from {
    my ($self) = @_;
    return $self->{from}; 
}

sub to {
    my ($self) = @_;
    return $self->{to};
}

1;

