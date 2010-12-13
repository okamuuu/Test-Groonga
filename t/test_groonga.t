use strict;
use warnings;
use Carp ();
use Test::More;
use Test::Exception;

### TODO: Where is the BEST PRACTICE How to do this
if ( $Class::Accessor::Lite::VERSION < 0.04 ) {
    Carp::croak "Test::Groonga use read-only accessor "
      . "via Class::Accessor::Lite newer than version 0.04 ...";
}

BEGIN { use_ok 'Test::Groonga' }

subtest 'test groonga utility CLASS METHODS.' => sub {

    my $path = Test::Groonga->which_groonga_cmd;
    ok( $path, "I find groonga command: $path" );

    ok( Test::Groonga->can_groonga_cmd,
        'And it is executable.' );
    
    my $port = Test::Groonga->get_empty_port;
    ok $port, "get empty port ok: $port";
};

subtest 'create instance.' => sub {

    my $groonga = Test::Groonga->new();
    isa_ok( $groonga, "Test::Groonga" );

    ok ! $groonga->port,  "Still not set port.";
    ok $groonga->temp_db, "This instance has temporary file: @{[$groonga->temp_db]}";
    
    ok ! $groonga->is_running;
    lives_ok { $groonga->start } 'start groonga daemon.';
    ok $groonga->is_running;
    lives_ok { $groonga->stop  } 'stop groonga daemon.';
    ok ! $groonga->is_running;
};

subtest 'create instance as httpd.' => sub {

    my $groonga = Test::Groonga->new(protocol => 'http');
    isa_ok( $groonga, "Test::Groonga" );

    ok ! $groonga->port,  "Still not set port.";
    ok $groonga->temp_db, "This instance has temporary file: @{[$groonga->temp_db]}";
    
    ok ! $groonga->is_running;
    lives_ok { $groonga->start } 'start groonga daemon.';
    ok $groonga->is_running;
    lives_ok { $groonga->stop  } 'stop groonga daemon.';
    ok ! $groonga->is_running;
};


done_testing;



