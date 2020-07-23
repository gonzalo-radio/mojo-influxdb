use strict;
use warnings;
package Mojo::InfluxDB;

# ABSTRACT: Super simple InfluxDB async client

use Mojo::Base -base, -signatures;
use Mojo::Collection qw/ c /;
use List::MoreUtils qw/ zip /;

has 'host' => 'localhost';
has 'port' => '8006';
has 'ua'   => sub { Mojo::UserAgent->new };
has 'url'  => sub ( $self ) {
    Mojo::URL->new( sprintf( 'http://%s:%s', $self->host, $self->port ) );
};

sub query ( $self, $query, $database ) {
    my $rs;
    $self->query_p( $query, $database )->then(sub ( $tx ) {
        $rs = $tx->res->json();
    })->catch( sub ( $error ) {
        say "Error: $error";
    })->wait;
    $rs;
}

sub query_p ( $self, $query, $database ) {
    $query = join( ';', @$query ) if $query eq 'ARRAY';
    $self->ua->get_p( $self->_url('query')->query({ q => $query, db => $database }) );
}

sub get_points ( $self, $rs ) {
    c($rs->{results}[0]{series}->@*)->map(sub ( $serie ) {
        my @columns = $_->{columns}->@*;
        c($serie->{values}->@*)->map(sub {
            +{ zip(@columns, $_->@*), ( $serie->{tags} ? $serie->{tags}->%* : () ) }
        });
    })->flatten->compact;
}

sub _url ( $self, $action ) { $self->url->path("/$action")->clone }

1;

=encoding utf8

=head1 NAME

Mojo::InfluxDB::Tiny - TODO

=head1 SYNOPSIS
    use Mojo::InfluxDB::Tiny;
    my $client = Mojo::InfluxDB::Tiny->new;

    my $result_set = $client->query('SELECT last("state") AS "last_state" FROM "telegraf"."thirty_days"."mongodb" WHERE time > now() - 5m AND time < now() AND "host"=\'mongodb01\' GROUP BY time(1h), "host"', 'telegraf');

    $client->get_points($result_set);

=head1 DESCRIPTION

TODO

=head1 ATTRIBUTES

=head1 METHODS

=head2 get_points

=head2 query

=head2 query_p

=head1 AUTHOR

Gonzalo Radio Navarro - gonzalo@gnzl.net

=head1 COPYRIGHT AND LICENSE

TODO

=head1 SEE ALSO

TODO

=cut
