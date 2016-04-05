package Local::Iterator::Interval;

use strict;
use warnings;
use DateTime;
use DateTime::Duration;
use Local::Interval;
use Moose;

with 'Local::Iterator';

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

has step => (
    is => 'ro',
    isa => 'DateTime::Duration',
    required => 1,
);

has length => (
    is => 'ro',
    isa => 'DateTime::Duration',
    lazy => 1,
    builder => '_build_length',
);

has _shift => (
    is => 'rw',
    isa => 'DateTime',
    lazy => 1,
    init_arg => undef,
    builder => '_build_shift',
);

sub _build_length {
    my ($self) = @_;
    return $self->step;
}

sub _build_shift {
    my ($self) = @_;
    return $self->from->clone;
}

sub _earliest {
    my ($dt1, $dt2) = @_; 

    my $cmp = DateTime->compare($dt1, $dt2);

    return $cmp < 0 ? $dt1 : $dt2;
}

sub _make_step {
    my ($self) = @_;

    $self->_shift->add_duration($self->step);

    $self->_shift(_earliest($self->_shift, $self->to));
}

sub _get_interval {
    my ($self) = @_;

    my $next_to   = $self->_shift->clone;
    $next_to->add_duration($self->length); 

    my $to = _earliest($next_to,  $self->to);

    return Local::Interval->new(
        from => $self->_shift->clone,
        to   => $to->clone,
    );
}

sub next {
    my ($self) = @_;

    my $left = $self->to->subtract_datetime($self->_shift);
    
    return (undef, 1)
        if DateTime::Duration->compare($left, $self->length, $self->from) < 0;

    my $interval = $self->_get_interval;

    $self->_make_step;

    return $interval;
}
    
1;
