package Test::Groonga;
use strict;
use warnings;
use File::Spec ();
use File::Temp ();
use IO::Socket::INET;
use Time::HiRes ();
use Class::Accessor::Lite;
Class::Accessor::Lite->mk_accessors(qw/pid port protocol host temp_db/);

use Data::Dumper;

our $VERSION = '0.00001';

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{ $_[0] } : @_;

    bless {
        port    => undef,
        host    => 'localhost',
        temp_db => File::Spec->catfile(
            File::Temp::tempdir( CLEANUP => 1 ),
            'test.groonga.db'
        ),
    }, $class;
}

sub start {
    my $self = shift;

    my $groonga_cmd = $self->which_groonga_cmd;
    my $port        = $self->port || 19000;
    my $host        = $self->host; 
    my $temp_db     = $self->temp_db;

    if ( $port !~ m/^[0-9]+/ or $port < 19000 ) {
        $port = 19000;
    }
   
    my $sock;
    while ( $port++ < 20000 ) {
        $sock = IO::Socket::INET->new(
            Listen    => 5,
            LocalAddr => '127.0.0.1',
            LocalPort => $port,
            Proto     => 'tcp',
            (($^O eq 'MSWin32') ? () : (ReuseAddr => 1)),
        );
        last if $sock;
    }
    if (! $sock) {
        die "empty port not found";
    }
    $sock->close; 
 
    $self->port($port);

    `$groonga_cmd -p $port -d -n $temp_db`;

    ### TODO: catch and hide errstr
    my $retry = 100;
    while ( $retry-- ) {
        ### wating groonga worked.
        return if `$groonga_cmd -p $port -c $host status`;
        Time::HiRes::sleep(0.1);
    }
    
    die "cannot open port: $port";
}

sub stop {
    my $self = shift;

    my $groonga_cmd = $self->which_groonga_cmd;
    my $port        = $self->port;
    my $temp_db     = $self->temp_db;
    my $host        = $self->host;

    `$groonga_cmd -p $port -c $host shutdown`
      or die "failed to shutdowon groonga daemon...";
}

sub can_groonga_cmd {
    return -x $_[0]->which_groonga_cmd ? 1 : 0;
}

sub which_groonga_cmd {
    my $path = `which groonga 2> /dev/null`;
    chomp($path);
    return $path;
}

=pod
sub DESTROY {
    my $self = shift;
    $self->stop
        if defined $self->pid && $$ == $self->_owner_pid;
}

sub start {

    $sock = IO::Socket::INET->new(
        Listen    => 5,
        LocalAddr => '127.0.0.1',
        LocalPort => $port,
        Proto     => 'tcp',
        ( ( $^O eq 'MSWin32' ) ? () : ( ReuseAddr => 1 ) ),
    );

}
=cut

1;

__END__

=head1 NAME

Test::Groonga::Httpd -

=head1 SYNOPSIS

  use Test::Groonga::Httpd;

=head1 DESCRIPTION

Test::Groonga::Httpd is

=head1 AUTHOR

okamuuu E<lt>okamuuu@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
