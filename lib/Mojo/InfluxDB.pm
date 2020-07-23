use strict;
use warnings;
package Mojo::InfluxDB;

# ABSTRACT: Super simple InfluxDB async client

use Mojo::Base -base, -signatures;
use Mojo::Collection qw/ c /;

use Mojo::InfluxDB::Result;
use Mojo::InfluxDB::Row;

has 'host' => 'localhost';
has 'port' => '8006';
has 'ua'   => sub { Mojo::UserAgent->new };
has 'url'  => sub ( $self ) {
    Mojo::URL->new( sprintf( 'http://%s:%s', $self->host, $self->port ) );
};

sub query ( $self, $query, $database ) {
    my $results;

    $self->query_p( $query, $database )->then(sub ( $tx ) {
        $results = c($tx->res->json('/results')->@*)->map(sub{
            my $series = delete $_->{series};
            my $result = Mojo::InfluxDB::Result->new(%$_);
            $result->series( c($series->@*)->map(sub{ Mojo::InfluxDB::Row->new(%$_) })->compact );
            $result;
        })->compact;
    })->catch( sub ( $error ) {
        say "Error: $error";
    })->wait;

    $results;
}

sub query_p ( $self, $query, $database ) {
    $query = join( ';', @$query ) if $query eq 'ARRAY';
    $self->ua->get_p( $self->_url('query')->query({ q => $query, db => $database }) );
}

sub _url ( $self, $action ) { $self->url->path("/$action")->clone }

1;

=encoding utf8

=head1 NAME

Mojo::InfluxDB::Tiny - TODO

=head1 SYNOPSIS
    use Mojo::InfluxDB::Tiny;
    my $client = Mojo::InfluxDB->new;

    my $result = $client->query('SELECT last("state") AS "last_state" FROM "telegraf"."thirty_days"."mongodb" WHERE time > now() - 5m AND time < now() AND "host"=\'mongodb01\' GROUP BY time(1h), "host"', 'telegraf');

    $client->first->points;

=head1 DESCRIPTION

TODO

=head1 ATTRIBUTES

=head1 METHODS

=head2 query

=head2 query_p

=head1 AUTHOR

Gonzalo Radio Navarro - gonzalo@gnzl.net

=head1 COPYRIGHT AND LICENSE

TODO

=head1 SEE ALSO

TODO

=cut
