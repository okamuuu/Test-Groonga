package Test::Groonga;
use strict;
use warnings;
use File::Spec ();
use File::Temp ();
use IO::Socket::INET;
use Time::HiRes ();
use Class::Accessor::Lite ( 
    ro => [qw/host protocol temp_db/],
    rw => [qw/port/]
);

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;

    bless {
        host     => 'localhost',
        protocol => $args{protocol} || undef,
        temp_db  => File::Spec->catfile(
            File::Temp::tempdir( CLEANUP => 1 ),
            'test.groonga.db'
        ),
    }, $class;
}

sub start {
    my $self = shift;

    Carp::croak('Already running...') if $self->is_running;

    my $groonga_cmd = $self->which_groonga_cmd;
    my $host        = $self->host; 
    my $temp_db     = $self->temp_db;

    my $port = $self->get_empty_port();
    $self->port($port);

    my $cmd =
      ( $self->protocol and $self->protocol eq 'http' )
      ? "$groonga_cmd -p $port --protocol http -d -n $temp_db 2> /dev/null"
      : "$groonga_cmd -p $port                 -d -n $temp_db 2> /dev/null";

    system($cmd);

    for ( 0 .. 100 ) {
        return if $self->is_running;
        Time::HiRes::sleep(0.1);
    }
    
    die "cannot running groonga :(";
}

sub is_running {
    my $self = shift;

    my $port = $self->port or return 0;

    my $groonga_cmd = $self->which_groonga_cmd;
    my $host        = $self->host;

    if ( $self->protocol and $self->protocol eq 'http' ) {
        require LWP::Simple;
        ### XXX: LWP::Simple::head is balkiness :( 
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

    my $groonga_cmd = $self->which_groonga_cmd;
    my $port        = $self->port;
    my $temp_db     = $self->temp_db;
    my $host        = $self->host;
    
    if ( $self->protocol and $self->protocol eq 'http' ) {
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
    my $self = shift;

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

sub DESTROY {
    my $self = shift;
    $self->stop if $self->is_running;
}

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

=head1 AUTHOR

Okamura. 

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


