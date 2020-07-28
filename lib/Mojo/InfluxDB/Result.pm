use strict;
use warnings;
package Mojo::InfluxDB::Result;

use Mojo::Base -base, -signatures;

has [qw/ series messages error statement_id /];

sub points ( $self ) {
    $self->series->map(sub{ $_->points })->flatten->compact;
}

1;

=encoding utf8

=head1 NAME

Mojo::InfluxDB::Result

=head1 SYNOPSIS

=cut
