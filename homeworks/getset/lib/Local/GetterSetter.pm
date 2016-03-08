package Local::GetterSetter;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::GetterSetter - getters/setters generator

=head1 VERSION

Version 1.01

=cut

our $VERSION = '1.01';

=head1 SYNOPSIS

    package Local::SomePackage;
    use Local::GetterSetter qw(x y);

    set_x(50);
    print our $x; # 50

    our $y = 42;
    print get_y(); # 42
    set_y(11);
    print get_y(); # 11

=cut

sub create_getset {
    my ($package, $var) = @_;

    {
        no strict 'refs'; 

        *{ "${package}::get_$var" }
            = sub { return ${ "${package}::$var" }; };

        *{ "${package}::set_$var" }
            = sub { ${ "${package}::$var" } = $_[0]; };
    }
}

sub import {
    my ($package) = caller();
    my ($class, @vars) = @_;

    for my $var (@vars) {
        create_getset($package, $var);
    }
}

1;
