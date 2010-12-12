use strict;
use warnings;
use Test::More;
use Test::Exception;
use LWP::Simple;
use JSON;

BEGIN { use_ok 'Test::Groonga' }

subtest 'test groonga utility methods.' => sub {

    my $path = Test::Groonga->which_groonga_cmd;
    ok( $path, "I find groonga command: $path" );
    ok( Test::Groonga->can_groonga_cmd,
        'And it is executable.' );
};

subtest 'create instance.' => sub {

    my $groonga = Test::Groonga->new();
    isa_ok( $groonga, "Test::Groonga" );

    ok ! $groonga->port,  "This case I don't spcified port.";
    ok $groonga->temp_db, "This instance has temporary file: @{[$groonga->temp_db]}";

#    lives_ok { $groonga->start } 'Now start groonga daemon';
    $groonga->start;
    $groonga->stop;
};

done_testing;

