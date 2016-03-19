package Local::JSONParser::Parser;

use strict;
use warnings;
use 5.010;
no warnings 'experimental';
use base qw(Exporter);
our @EXPORT_OK = qw(parse);
use Local::JSONParser::Lexer qw(token_type token_data);

my $tokens;

sub pop_token {
    my $token = shift(@$tokens) // die('Not enough tokens');
    my $check = shift           // return $token;

    die("$check token expected") if $check ne token_type($token);

    return $token;
}

sub top_token {
    my $token = $tokens->[0] // die('Not enough tokens');
    my $check = shift        // return token_type($token);

    return $check eq token_type($token);
}

sub object {
    pop_token('BRACE_LEFT');
    my %object;
    if (!top_token('BRACE_RIGHT')) {
        while (1) {
            my $key = pop_token('STRING');
            pop_token('COLON');
            my $value = value();
            $object{token_data($key)} = $value;
        } continue {
            last if top_token('BRACE_RIGHT');
            pop_token('COMMA');
        }
    }
    pop_token('BRACE_RIGHT');
    
    return \%object;
}

sub array { 
    pop_token('BRACKET_LEFT');
    my @array;
    if (!top_token('BRACKET_RIGHT')) {
        while (1) {
            my $value = value();
            push @array, $value;
        } continue {
            last if top_token('BRACKET_RIGHT');
            pop_token('COMMA');
        }
    }
    pop_token('BRACKET_RIGHT');

    return \@array;
}

sub value {
    given (top_token()) {
        when ('BRACE_LEFT') {
            return object(); 
        }
        when ('BRACKET_LEFT') {
            return array(); 
        }
        when (['STRING', 'NUMBER']) {
            return token_data(pop_token());
        }
        default {
            die('Wrong value');
        }
    }
}

sub parse {
    $tokens = shift;

    my $value = value();

    return $value;
}

1;
