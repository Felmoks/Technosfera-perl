package Local::JSONParser::Lexer;

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT_OK = qw(tokenize token_type token_data);

my %tokens = (
    'WHITESPACE'    => qr/\s+/,
    'BRACE_LEFT'    => qr/\{/,
    'BRACE_RIGHT'   => qr/\}/,
    'BRACKET_LEFT'  => qr/\[/,
    'BRACKET_RIGHT' => qr/\]/,
    'COLON'         => qr/:/,
    'COMMA'         => qr/,/,
    'STRING'        => qr/"(?:\\.|[^\"])*+"/,
    'NUMBER'        => qr/[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?/,
);

sub token_type {
    return $_[0]->{type};
}

sub token_data {
    return $_[0]->{data};
}

sub tokenize {
    my ($text) = @_;
    my @tokens;

    $text =~ m//g;

    POSITION:
    while (pos($text) < length($text)) {
        while (my ($token, $pattern) = each %tokens) {
            if ($text =~ /\G(?<data>$pattern)/gc) {
                my $data = $+{data};
                if ($token eq 'STRING') {
                    $data =~ s/\\u(\d{1,4})/\\x{$1}/g; 
                    $data = eval qq{$data};
                }
                elsif ($token eq 'NUMBER') {
                    $data = 0+ $data;
                }
                push @tokens, { type => $token, data => $data } if $token ne 'WHITESPACE'; 
                next POSITION;
            }
        }
        die("Unexpected token here: " . substr($text, pos($text)));
    } continue {
        keys %tokens;
    }

    return \@tokens;
}

1;
