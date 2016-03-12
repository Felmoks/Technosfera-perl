package Local::MusicLibrary;

use strict;
use warnings;
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(parse);

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub parse {
    my @songs;
    while (my $line = <>) {
        chomp($line);
        my @data = split '/', $line;
        @data = ($data[1], split(' - ', $data[2]), split('\.', $data[3]));
        my %song = (
            band   => $data[0],
            year   => $data[1],
            album  => $data[2],
            track  => $data[3],
            format => $data[4],
        );
        push @songs, \%song;
    }
    print Dumper \@songs;
    return \@songs;
}



1;
