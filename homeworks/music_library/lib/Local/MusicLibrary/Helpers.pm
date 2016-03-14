package Local::MusicLibrary::Helpers;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(process_query filter_library sort_library extract_columns);

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

my %default_query = (
    filter  => {},
    columns => 'band,year,album,track,format',
    sort    => '',
);


sub filter_library {
    my ($library, $query) = @_;
    return [ @$library ] if (keys %$query) == 0;

    my $is_valid = sub {
        my $valid = 1;

        for my $key (keys %$query) {
            $valid &&= $fields{$key}{is_equal}($_[0]->{$key}, $query->{$key});
        }

        return $valid;
    };

    my @selected = grep { $is_valid->($_) } @$library;

    return \@selected;
}

sub sort_library {
    my ($library, $sort_fields) = @_;
    return [ @$library ] if @$sort_fields == 0;

    my $comparator = sub {
        for my $key (@$sort_fields) {
            my $order = $fields{$key}{compare}($a->{$key}, $b->{$key});
            return $order if $order != 0;
        } 
    };

    my @sorted = sort { $comparator->() } @$library;

    return \@sorted;
}

sub extract_columns {
    my ($library, $columns) = @_;
    return [] if @$columns == 0;

    my @data = map { [ @$_{@$columns} ] } @$library;
    return \@data;
}

sub process_query {
    my ($raw_query) = @_;

    my %query;

    my $columns = delete ${$raw_query}{columns};
    $columns = $columns // $default_query{columns};
    my @queried_fields = split /,/, $columns;

    my $sort = delete ${$raw_query}{sort};
    $sort = $sort // $default_query{sort};
    my @sort_fields = split /,/, $sort;

    my $filter = keys %$raw_query ? $raw_query : $default_query{filter};

    $query{filter}  = $filter,
    $query{columns} = \@queried_fields,
    $query{sort}    = \@sort_fields,

    return \%query;
}
