package Mojo::InfluxDB::Row;
# ABSTRACT: Result row container

use Mojo::Base -base, -signatures;
use Mojo::InfluxDB::Point;
use Mojo::Collection qw/ c /;
use List::MoreUtils qw/ zip /;

has 'time_zone';

has src => sub { die "This result is empty" };

for my $field (qw/ names tags columns values partial /) {
    has $field => sub($self){ $self->src->{$field} };
}

has points => sub($self) {
    c( $self->values->@* )->map(sub {
        Mojo::InfluxDB::Point->inflate(+{
            zip( $self->columns->@*, $_->@* ),
            ( $self->tags ? $self->tags->%* : () )
        });
    })
};

1;

=head1 SYNOPSIS

See L<InfluxDB> and L<InfluxDB::Result>.

=head1 ATTRIBUTES

=attr src

this is where L<InfluxDB::Result> will store the raw data retrieved for this row. Most attributes of this class will read from here.

=attr time_zone

an optional time_zone that will be passed into every L<Mojo::InfluxDB::Point> returned by points().

=attr names

=attr tags

=attr columns

=attr values

=attr partial

=attr points

A L<Mojo::Collection> of L<Mojo::InfluxDB::Point>.

=cut
