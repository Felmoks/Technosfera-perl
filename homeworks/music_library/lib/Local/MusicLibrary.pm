package Local::MusicLibrary;

use strict;
use warnings;
use Data::Dumper;
use Local::MusicLibrary::Helpers qw(process_query filter_library sort_library extract_columns);
use Exporter 'import';

our @EXPORT_OK = qw(read_library get_songs);

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get_songs {
    my ($songs, $query) = @_;

    my $selected = filter_library($songs, $query->{filter});
    return [] if @$selected == 0;

    $selected = sort_library($selected, $query->{sort});

    $selected = extract_columns($selected, $query->{columns});

    return $selected;
}

sub read_library {
    my @songs;

    while (my $line = <>) {
        chomp($line);

        my @data = split m{/}, $line;

        my %song;
        @song{qw(band year album track format)}
            = ($data[1], split(/ - /, $data[2]), split(/\./, $data[3]));

        push @songs, \%song;
    }

    return \@songs;
}

1;
