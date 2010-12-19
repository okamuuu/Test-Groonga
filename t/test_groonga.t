use strict;
use warnings;
use Carp ();
use Test::More;
use Test::Exception;
use Data::Dumper;
BEGIN { use_ok 'Test::Groonga' }

my $bin = scalar File::Which::which('groonga');
plan skip_all => 'groonga binary is not found' unless defined $bin;

subtest 'get test tcp instance as groonga server in gqtp mode' => sub {
    my $server;
    lives_ok { $server = Test::Groonga->gqtp } "create Test::TCP instance.";
    ok $server->port, "port: @{[ $server->port ]}";
    ok $server->pid,  "pid:  @{[ $server->pid  ]}";
    lives_ok { $server->stop  } 'stop server.';
    ok ! $server->pid, "As a result, this instacne has no pid.";
};

subtest 'get test tcp instance as groonga server in http mode' => sub {
    my $server;
    lives_ok { $server = Test::Groonga->http } "create Test::TCP instance.";
    ok $server->port, "port: @{[ $server->port ]}";
    ok $server->pid,  "pid:  @{[ $server->pid  ]}";
    lives_ok { $server->stop  } 'stop server.';
    ok ! $server->pid, "As a result, this instacne has no pid.";
};


done_testing;



