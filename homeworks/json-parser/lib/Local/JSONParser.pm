package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
use Local::JSONParser::Lexer qw(tokenize);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );

sub parse_json {
	my $source = shift;
	
    #use JSON::XS;
	# return JSON::XS->new->utf8->decode($source);

    my $tokens = tokenize($source);

	return $tokens;
}

1;
