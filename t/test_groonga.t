use strict;
use warnings;
use Carp ();
use Test::More;
use Test::Exception;
use LWP::UserAgent;

BEGIN { use_ok 'Test::Groonga' }

my $bin = Test::Groonga::_find_groonga_bin();
plan skip_all => 'groonga binary is not found' unless defined $bin;

subtest 'get test tcp instance as groonga server in gqtp mode' => sub {

    my $server;
    lives_ok { $server = Test::Groonga->gqtp } "create Test::TCP instance.";

    my $port = $server->port;
    ok $port, "port: $port";
   
    my $json = `$bin -p $port -c 127.0.0.1 status`;     
    ok $json =~ m/^\[\[0/, "groonga server is running in gqtp mode.";

    $server->stop; 
};

subtest 'get test tcp instance as groonga server in http mode' => sub {

    my $server;
    lives_ok { $server = Test::Groonga->http } "create Test::TCP instance.";

    my $port = $server->port;
    ok $port, "port: $port";

    my $url = "http://127.0.0.1:$port/d/status";
    my $res = LWP::UserAgent->new()->get($url);
    is $res->code, 200, "groonga server is running in http mode";
    diag "content: " . $res->content;
 
    $server->stop; 
};


done_testing;



