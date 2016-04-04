package Local::Iterator;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Iterator - base abstract iterator

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;
    $self->init(%args);
    return $self;
}

sub init {
    die 'Unimplemented';
}

sub next {
    die 'Unimplemented';
}

sub all {
    my ($self) = @_;
    my @rest = ();

    my ($val, $end) = $self->next;
    while (!$end) {
        push @rest, $val;
        ($val, $end) = $self->next;
    }

    return \@rest;
}

1;
