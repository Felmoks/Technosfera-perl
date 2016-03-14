package Local::MusicLibrary;

use strict;
use warnings;
use Data::Dumper;
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

my $streq  = sub { $_[0] eq  $_[1] };
my $strcmp = sub { $_[0] cmp $_[1] };
my $numeq  = sub { $_[0] ==  $_[1] };
my $numcmp = sub { $_[0] <=> $_[1] };

my %fields = (
    band   => {
        is_equal => $streq,
        compare  => $strcmp,
    },

    year   => {
        is_equal => $numeq,
        compare  => $numcmp,
    },

    album   => {
        is_equal => $streq,
        compare  => $strcmp,
    },

    track   => {
        is_equal => $streq,
        compare  => $strcmp,
    },

    format  => {
        is_equal => $streq,
        compare  => $strcmp,
    },
);

sub get_songs {
    my ($songs, $query) = @_;

    my $columns = delete ${$query}{columns};
    my $sort    = delete ${$query}{sort};

    #Filter
    my $is_selected = sub {
        my $valid = 1;

        for my $key (keys %$query) {
            $valid &&= $fields{$key}{is_equal}($_[0]->{$key}, $query->{$key});
        }

        return $valid;
    };
    my @selected = grep { $is_selected->($_) } @$songs;
    return [] if @selected == 0;

    #Sort
    if (defined $sort) {
        my @sort_fields = split /,/, $sort;
        my $comparator = sub {
            for my $key (@sort_fields) {
                my $order = $fields{$key}{compare}($a->{$key}, $b->{$key});
                return $order if $order != 0;
            } 
        };
        @selected = sort { $comparator->() } @selected;
    }

    #Extract columns
    $columns = $columns // 'band,year,album,track,format';
    return [] if $columns eq '';
    my @keys = split /,/, $columns;
    @selected = map { [ @$_{@keys} ] } @selected;

    return \@selected;
}

sub read_library {
    my @songs;

    while (my $line = <>) {
        chomp($line);

        my @data = split |/|, $line;

        my %song;
        @song{qw(band year album track format)}
            = ($data[1], split(/ - /, $data[2]), split(/\./, $data[3]));

        push @songs, \%song;
    }

    return \@songs;
}


1;
