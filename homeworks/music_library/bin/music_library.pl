#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Local::MusicLibrary qw(read_library get_songs);
use Local::MusicLibrary::BlockBuilder  qw(build_block);
use Local::MusicLibrary::BlockRenderer qw(render_block);
use Local::MusicLibrary::Helpers qw(process_query);
use Data::Dumper;

my %raw_query;

GetOptions(
    \%raw_query,
        'band=s'   , 
        'year=s'   , 
        'album=s'  , 
        'track=s'  , 
        'format=s' , 
        'sort=s'   , 
        'columns=s', 
);

my $songs = read_library();

my $query = process_query(\%raw_query);

my $select = get_songs($songs, $query);

my $block = build_block($select);

my $output = render_block($block);

print $output;
