use strict;
use warnings;
package Mojo::InfluxDB::Row;

use Mojo::Base -base, -signatures;
use Mojo::Collection qw/ c /;
use List::MoreUtils qw/ zip /;
use DateTime;
use DateTime::Format::Strptime;

has [qw/ names tags columns values partial time_zone /];

has _strp => sub {
    DateTime::Format::Strptime->new( pattern => '%FT%T%Z' )
};

sub points ( $self ) {
    my @columns = $self->columns->@*;
    c( $self->values->@* )->map(sub {
        my $value = +{
            zip( @columns, $_->@* ),
            ( $self->tags ? $self->tags->%* : () )
        };

        if ( $self->time_zone && $value->{time} ) {
            my $dt = $self->_strp->parse_datetime(
                $value->{time}
            )->set_time_zone( $self->time_zone );

            $value->{time}      = "$dt";
            $value->{epoch}     = $dt->epoch;
            $value->{time_zone} = $self->time_zone;
        }

        $value;
    })->compact;
}

1;

=encoding utf8

=head1 NAME

Mojo::InfluxDB::Row

=head1 SYNOPSIS

=cut
