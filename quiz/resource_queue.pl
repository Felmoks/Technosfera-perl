use strict;
use warnings;

use 5.010;

use JSON::XS;
use Data::Dumper;

open my $fh, '<', 'resource_queue.jsonl' or die('Cannot open jsons');

my $coder = JSON::XS->new->ascii;

my %resources;
my %consumers;

my $current_hash = \%resources;

while (my $line = <$fh>) {
    chomp($line);
    #Change hash for filling from input on empty line
    if (length($line) == 0) {
        $current_hash = \%consumers;
        next;
    }

    my $object = $coder->decode($line);

    #Use name as hash key and drop it from input object
    my $name = $object->{name};
    delete $object->{name};
    $current_hash->{$name} = $object;
}

close $fh;

for my $name (keys %consumers) {
    #Reduce capacity of all used resources
    for my $res (keys %{ $consumers{$name}{resources} }) {
        $resources{$res}{capacity} -= $consumers{$name}{resources}{$res};
    }

    #Check for exhausted resources
    if (grep { $resources{$_}{capacity} >= 0 } keys %{ $consumers{$name}{resources} }) {
        say $name;
    }
}
