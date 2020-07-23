use strict;
use warnings;
package Mojo::InfluxDB::Tiny;

# ABSTRACT: Super simple InfluxDB async client

use common::sense;
use Mojo::Base -base, -signatures;
use Mojo::Collection qw/ c /;
use List::MoreUtils qw/ zip /;

has 'host';
has 'port';
has 'ua'  => sub { Mojo::UserAgent->new };
has 'url' => sub ( $self ) {
    my $url = Mojo::URL->new( sprintf( 'http://%s:%s', $self->host, $self->port ) );
    {
        base  => $url->clone,
        query => $url->clone->path('/query'),
        ping  => $url->clone->path('/ping'),
        write => $url->clone->path('/write')
    };
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
    $self->ua->get_p( $self->query_url->query({ q => $query, db => $database }) );
}

sub get_points ( $self, $rs ) {
    my @results;
    my $series = $rs->{results}[0]{series};
    for my $serie ($series->@*) {
        my @columns = $serie->{columns}->@*;
        for my $value ($serie->{values}->@*) {
            push @results, +{ zip(@columns, $value->@*), ( $serie->{tags} ? $serie->{tags}->%* : () ) };
        }
    }
    c(@results);
}

sub query_url ( $self ) { $self->_url('query') }
sub write_url ( $self ) { $self->_url('write') }
sub ping_url ( $self )  { $self->_url('ping') }
sub _url ( $self, $type ) { $self->url->{$type}->clone }

1;

=encoding utf8

=head1 NAME

Mojo::InfluxDB::Tiny - TODO

=head1 SYNOPSIS
    use Mojo::InfluxDB::Tiny;
    my $client = Mojo::InfluxDB::Tiny->new( host => '127.0.0.1', port => '8086' );

    my $result_set = $client->query('SELECT last("state") AS "last_state" FROM "telegraf"."thirty_days"."mongodb" WHERE time > now() - 5m AND time < now() AND "host"=\'mongodb01\' GROUP BY time(1h), "host"', 'telegraf');

    $client->get_points($result_set);

=head1 DESCRIPTION

TODO

=head1 ATTRIBUTES

=head1 METHODS

=head2 get_points

=head2 ping_url

=head2 query

=head2 query_p

=head2 query_url

=head2 write_url

=head1 AUTHOR

Gonzalo Radio Navarro - gonzalo@gnzl.net

=head1 COPYRIGHT AND LICENSE

TODO

=head1 SEE ALSO

TODO

=cut
