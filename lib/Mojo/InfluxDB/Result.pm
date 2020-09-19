package Mojo::InfluxDB::Result;
# ABSTRACT: Result container for queries

use Mojo::Base -base, -signatures;
use Mojo::Collection qw/ c /;
use Mojo::InfluxDB::Row;

has src => sub { die "This result is empty" };
has 'time_zone';

for my $field (qw/ series messages error statement_id /) {
    has $field => sub($self){ $self->src->{$field} };
}

has series => sub($self) {
    c( $self->src->{series}->@* )->map(sub{
        Mojo::InfluxDB::Row->new(
            src       => $_,
            time_zone => $self->time_zone
        )
    })
};

sub points ( $self ) {
    $self->series->map(sub{ $_->points })->flatten;
}

1;

=head1 DESCRIPTION

You will get this objects form L<InfluxDB> query methods. This is a container of query results.

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
