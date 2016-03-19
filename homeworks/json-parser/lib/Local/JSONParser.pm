package Local::JSONParser;

use strict;
use warnings;
use base qw(Exporter);
use Local::JSONParser::Lexer qw(tokenize);
use Local::JSONParser::Parser qw(parse);
our @EXPORT_OK = qw( parse_json );
our @EXPORT = qw( parse_json );


=encoding utf8

=head1 NAME

Local::JSONParser - JSON Parser

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

    package Local::SomePackage;
    use Local::JSONParser 'parse_json';

    my $data = parse_json( $source );

=cut

sub parse_json {
	my $source = shift;
	
    #use JSON::XS;
	# return JSON::XS->new->utf8->decode($source);

    my $tokens = tokenize($source);
    my $result = parse($tokens);

	return $result; 
}

1;
