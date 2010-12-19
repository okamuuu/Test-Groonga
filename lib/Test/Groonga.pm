package Test::Groonga;
use strict;
use warnings;
use File::Spec ();
use File::Temp ();
use File::Which ();
use Test::TCP 1.10;

our $VERSION = '0.03';

sub gqtp { _get_test_tcp('gqtp') }

sub http { _get_test_tcp('http') }

sub _get_test_tcp {
    my $protocol = shift;
 
    my $bin = _find_groonga_bin();
    Carp::croak('groonga binary is not found') unless $bin;

    ### groonga create some shard files. 
    ### ex. tmp/test.groonga.db, tmp/test.groonga.db.0000000, ...
    my $db = File::Spec->catfile( File::Temp::tempdir( CLEANUP => 1 ),
        'test.groonga.db' );

    return my $server = Test::TCP->new(
        code => sub {
            my $port = shift;

            # -s : server mode
            # -n : create a new database
            exec $bin, '-s', '--port', $port, '--protocol', $protocol, '-n', $db;
            die "cannot execute $bin: $!";
        },  
    ); 
}

sub _find_groonga_bin { scalar File::Which::which('groonga'); }

1;

__END__

=head1 NAME

Test::Groonga -  Groonga Runner For Tests

=head1 SYNOPSIS

  use Test::Groonga;
 
  my $groonga = Test::Groonga->new();
  
  $groonga->start;
  $groonga->stop;

=head1 DESCRIPTION

Test::Groonga provides you temporary groonga server daemon.

I also shamelessly stole from Test::Memcached.
So this interface similar to it.

=head1 METHODS

=head2 new

=head2 start

=head2 is_running

=head2 stop

=head2 can_groonga_cmd

=head2 which_groonga_cmd

=head2 get_empty_port

=head2 DESTROY 

=head1 AUTHOR

Okamura. 

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


