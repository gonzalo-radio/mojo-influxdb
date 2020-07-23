use strict;
use warnings;
package Mojo::InfluxDB::Result;

use Mojo::Base -base, -signatures;

has 'series';
has 'messages';
has 'error';
has 'statement_id';

sub points ( $self ) {
    $self->series->map(sub{ $_->points })->flatten->compact;
}

1;
