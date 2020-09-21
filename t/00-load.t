use Test::More tests => 1;

BEGIN {
	use_ok( 'Mojo::InfluxDB' );
}

diag( "Testing Resque $Resque::VERSION, Perl $], $^X" );
