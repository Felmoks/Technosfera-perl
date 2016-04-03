package Local::Interval;

use strict;
use warnings;
use Moose;

=encoding utf8

=head1 NAME

Local::Interval - time interval

=head1 SYNOPSIS

    my $interval = Local::Interval->new('...');

    $interval->from(); # DateTime
    $interval->to(); # DateTime

=cut

has from => (
    is => 'ro',
    isa => 'DateTime',
    required => 1,
);

has to => (
    is => 'ro',
    isa => 'DateTime',
    required => 1,
);

1;

