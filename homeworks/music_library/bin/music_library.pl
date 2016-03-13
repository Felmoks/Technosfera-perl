#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Local::MusicLibrary qw(read_library get_songs);
use Local::BlockBuilder  qw(build_block);
use Local::BlockRenderer qw(render_block);
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

my $m = build_block($select);

my $output = render_block($m);

print $output;
