package Test::Groonga;
use strict;
use warnings;
use File::Spec ();
use File::Temp ();
use File::Which ();
use Test::TCP 1.10;

our $VERSION = '0.04';

sub gqtp {
    my $class  = shift;
    my %args   = @_ == 1 ? %{ $_[0] } : @_;
    $class->_get_test_tcp( %args, protocol => 'gqtp');
}

sub http {
    my $class  = shift;
    my %args   = @_ == 1 ? %{ $_[0] } : @_;
    $class->_get_test_tcp( %args, protocol => 'http');
}

sub _get_test_tcp {
    my ($class, %args) = @_;
    
    my $preload  = $args{preload} || undef;
    my $protocol = $args{protocol} or die;
 
    ### load data from dump file if you specified it.
    if ($preload and not -e $preload) {
        Carp::croak("Couldn't find file: $preload");
    }

    my $bin = _find_groonga_bin();
    Carp::croak('groonga binary is not found') unless $bin;

    ### groonga create some shard files. 
    ### ex. tmp/test.groonga.db, tmp/test.groonga.db.0000000, ...
    
    my $db =
      File::Spec->catfile( File::Temp::tempdir( CLEANUP => 1 ), 'test.db' );
    
    return my $server = Test::TCP->new(
        code => sub {
            my $port = shift;

            my $result = `$bin -n $db < $preload` if $preload;
            
            # -s : server mode
            # -n : create a new db
            my @cmd =
              $preload
              ? ( $bin, '-s', '--port', $port, '--protocol', $protocol, $db )
              : ( $bin, '-s', '--port', $port, '--protocol', $protocol, '-n', $db );

            exec @cmd;
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


