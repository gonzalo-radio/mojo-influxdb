use strict;
use warnings;
package Mojo::InfluxDB::Row;

use Mojo::Base -base, -signatures;
use Mojo::Collection qw/ c /;
use List::MoreUtils qw/ zip /;

has 'name';
has 'tags';
has 'columns';
has 'values';
has 'partial';

sub points ( $self ) {
    my @columns = $self->columns->@*;
    c($self->values->@*)->map(sub {
        +{ zip(@columns, $_->@*), ( $self->tags ? $self->tags->%* : () ) }
    })->compact;
}

1;

