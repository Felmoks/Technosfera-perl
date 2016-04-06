package Local::Iterator::File;

use strict;
use warnings;
use parent 'Local::Iterator';

=encoding utf8

=head1 NAME

Local::Iterator::File - file-based iterator

=head1 SYNOPSIS

    my $iterator1 = Local::Iterator::File->new(filename => '/tmp/file');

    open(my $fh, '<', '/tmp/file2');
    my $iterator2 = Local::Iterator::File->new(fh => $fh);

=cut

sub init {
    my ($self, %args) = @_;

    if (defined $args{filename}) {
        open($self->{data}, '<', $args{filename});
    }
    elsif (defined $args{fh}) {
        $self->{data} = $args{fh};
    }
}

sub next {
    my ($self) = @_; 

    my $end = eof($self->{data});
    my $val = readline($self->{data});

    chomp($val) if defined $val;

    return ($val, $end);
}

1;
