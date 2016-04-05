package Local::Iterator::File;

use strict;
use warnings;
use Moose;

with 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::File - file-based iterator

=head1 SYNOPSIS

    my $iterator1 = Local::Iterator::File->new(filename => '/tmp/file');

    open(my $fh, '<', '/tmp/file2');
    my $iterator2 = Local::Iterator::File->new(fh => $fh);

=cut

has filename => (
    is => 'ro',
    isa => 'Str',
    predicate => '_has_filename',
);

has fh => (
    is => 'ro',
    isa => 'FileHandle',
    lazy => 1,
    predicate => '_has_fh',
    builder => '_build_fh',
);

sub BUILD {
    my ($self) = @_;

    confess 'You need to supply a filename or a filehandle'
        if !$self->_has_filename && !$self->_has_fh;
};

sub _build_fh {
    my ($self) = @_;

    open(my $fh, '<', $self->filename) or die "Cannot open: $!";
    return $fh;
}

sub next {
    my ($self) = @_; 

    my $end = eof($self->fh);
    my $val = readline($self->fh);

    chomp($val) if defined $val;

    return ($val, $end);
}

1;
