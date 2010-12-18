package Test::Groonga;
use strict;
use warnings;
use File::Spec ();
use File::Temp ();
use Time::HiRes ();
use IO::Socket::INET;

use Class::Accessor::Lite 0.05 ( ro => [qw/bin port host protocol temp_db/] );

our $VERSION = '0.02';

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;

    my $bin = $class->which_groonga_cmd;

    Carp::croak("not found cmd 'groonga'...") unless $bin;
    Carp::croak("Cannot implement 'groonga'...") unless $class->can_groonga_cmd;

    bless {
        bin      => $bin,
        host     => 'localhost',
        protocol => $args{protocol} || 'gqtp',
        temp_db  => File::Spec->catfile(
            File::Temp::tempdir( CLEANUP => 1 ),
            'test.groonga.db'
        ),
    }, $class;
}

sub start {
    my $self = shift;

    Carp::croak('Already running...') if $self->is_running;

    my $groonga_cmd = $self->bin;
    my $host        = $self->host; 
    my $protocol    = $self->protocol; 
    my $temp_db     = $self->temp_db;

    my $port = $self->get_empty_port();
    $self->{port} = $port;

    system("$groonga_cmd -p $port --protocol $protocol -d -n $temp_db 2> /dev/null");

    ### wait for port open
    for ( 0 .. 100 ) {
        return if $self->is_running;
        Time::HiRes::sleep(0.1);
    }
    
    die "cannot running groonga :(";
}

sub is_running {
    my $self = shift;

    my $port = $self->port;
    
    return unless $port;

    my $groonga_cmd = $self->bin;
    my $host        = $self->host;

    if ( $self->protocol eq 'http' ) {
        require LWP::Simple;
        my $content = LWP::Simple::get("http://localhost:$port/d/status");
        return $content ? 1 : 0;
    }
    else {
        ### BK: SEE ALSO https://github.com/schwern/test-more/issues/issue/83
        local $?;
        return `$groonga_cmd -p $port -c $host status 2> /dev/null` ? 1 : 0;
    }
}

sub stop {
    my $self = shift;

    my $groonga_cmd = $self->bin;
    my $port        = $self->port;
    my $temp_db     = $self->temp_db;
    my $host        = $self->host;
    
    if ( $self->protocol eq 'http' ) {
        my $content = LWP::Simple::get("http://localhost:$port/d/shutdown");
        die "failed to shutdowon groonga daemon..." unless $content;
    }
    else {
        my $result = `$groonga_cmd -p $port -c $host shutdown 2> /dev/null`;
        die "failed to shutdowon groonga daemon..." unless $result;
    }
}

sub can_groonga_cmd {
    return -x $_[0]->which_groonga_cmd ? 1 : 0;
}

sub which_groonga_cmd {
    my $path = `which groonga 2> /dev/null`;
    chomp($path);
    return $path;
}

sub get_empty_port {
    my $port = 19000; 
    my $sock;
    while ( $port++ < 20000 ) {
        $sock = IO::Socket::INET->new(
            Listen    => 5,
            LocalAddr => '127.0.0.1',
            LocalPort => $port,
            Proto     => 'tcp',
        );
        last if $sock;
    }
    die "empty port not found" unless $sock;

    $sock->close; 
    return $port;
}

sub DESTROY { $_[0]->stop if $_[0]->is_running; }

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


