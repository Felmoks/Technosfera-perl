package Local::Iterator;

use strict;
use warnings;
use Moose::Role;

=encoding utf8

=head1 NAME

Local::Iterator - base abstract iterator

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

requires 'next';

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
