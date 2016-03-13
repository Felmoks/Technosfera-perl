#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Local::MusicLibrary qw(parse get_songs);
use Local::TableRenderer qw(render_block);
use Local::TableBuilder  qw(build_matrix);
use Data::Dumper;

BEGIN{
	$|++;     # Enable autoflush on STDOUT
	$, = " "; # Separator for print x,y,z
	$" = " "; # Separator for print "@array";
}

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
my $songs = parse();
my $select = get_songs($songs, \%query);
exit if @$select == 0;
my $arr = [[11,2,3],[4,555,6],[7,8,2139]];
my $m = build_matrix($select);
my $output = render_block($m);

print $output;
