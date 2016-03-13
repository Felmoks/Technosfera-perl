#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Local::MusicLibrary qw(read_library get_songs);
use Local::TableRenderer qw(render_block);
use Local::TableBuilder  qw(build_matrix);
use Data::Dumper;

my %query;

GetOptions(
    \%query,
        'band=s'   , 
        'year=s'   , 
        'album=s'  , 
        'track=s'  , 
        'format=s' , 
        'sort=s'   , 
        'columns=s', 
);

my $songs = read_library();

my $select = get_songs($songs, \%query);
exit if @$select == 0;

my $m = build_matrix($select);

my $output = render_block($m);

print $output;
