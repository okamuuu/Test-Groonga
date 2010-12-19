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

Test::Groonga -  Server Runner For Testing Groonga full-text search engine

=head1 SYNOPSIS

    use Test::Groonga;

    {
        my $server = Test::Groonga->gqtp();
        # testing
    }

    {
        my $server = Test::Groonga->http();
        # testing
    }

=head1 DESCRIPTION

Test::Groonga provides you temporary groonga server.

=head1 METHODS

=head2 gqtp

return Test::TCP instance as groonga server.

=head2 http

return Test::TCP instance as groonga server. 

=head1 AUTHOR

Okamura. 

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


