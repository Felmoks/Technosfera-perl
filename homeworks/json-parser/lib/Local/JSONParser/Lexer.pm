package Local::JSONParser::Lexer;

use strict;
use warnings;
use 5.010;
use Data::Dumper;
use base qw(Exporter);
our @EXPORT_OK = qw(tokenize);

my %tokens = (
    'WHITESPACE'    => qr/\s+/,
    'BRACE_LEFT'    => qr/\{/,
    'BRACE_RIGHT'   => qr/\}/,
    'BRACKET_LEFT'  => qr/\[/,
    'BRACKET_RIGHT' => qr/\]/,
    'COLON'         => qr/:/,
    'COMMA'         => qr/,/,
    'TRUE'          => qr/true/,
    'FALSE'         => qr/false/,
    'NULL'          => qr/null/,
    'STRING'        => qr/"(?:\\.|[^\"])*+"/,
    'NUMBER'        => qr/[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?/,
);

sub tokenize {
    my ($text) = @_;
    my @tokens;

    print Dumper $text;

    $text =~ m//g;

    POSITION:
    while (pos($text) < length($text)) {
        keys %tokens;
        while (my ($token, $pattern) = each %tokens) {
            if ($text =~ /\G$pattern/gc) {
               push @tokens, $token if !($token eq 'WHITESPACE'); 
               next POSITION;
            }
        }
        die("Unexpected token at position:\n " . substr($text, pos($text)));
    }

    return \@tokens;
}

1;
