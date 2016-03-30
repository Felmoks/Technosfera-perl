package Local::App::GenCalc;

use strict;
use warnings;

use Local::App::SafeIO qw(:lockio socket_read socket_write);
use Fcntl qw(:seek);
use IO::Socket;
use Data::Dumper;
use Time::HiRes qw(alarm);
use POSIX;

my $file_path = './calcs.txt';

sub new_one {
    my $new_row = join $/, int(rand(5)).' + '.int(rand(5)), 
                  int(rand(2)).' + '.int(rand(5)).' * '.int(int(rand(10))), 
                  '('.int(rand(10)).' + '.int(rand(8)).') * '.int(rand(7)), 
                  int(rand(5)).' + '.int(rand(6)).' * '.int(rand(8)).' ^ '.int(rand(12)), 
                  int(rand(20)).' + '.int(rand(40)).' * '.int(rand(45)).' ^ '.int(rand(12)), 
                  (int(rand(12))/(int(rand(17))+1)).' * ('.(int(rand(14))/(int(rand(30))+1)).' - '.int(rand(10)).') / '.rand(10).'.0 ^ 0.'.int(rand(6)),  
                  int(rand(8)).' + 0.'.int(rand(10)), 
                  int(rand(10)).' + .5',
                  int(rand(10)).' + .5e0',
                  int(rand(10)).' + .5e1',
                  int(rand(10)).' + .5e+1', 
                  int(rand(10)).' + .5e-1', 
                  int(rand(10)).' + .5e+1 * 2';

    my $fh;
    safe_open($fh, '>>', $file_path, LOCK_EX);
    print $fh $new_row . "\n";
    safe_close($fh);

    die('Message buffer overflow') if +(stat $file_path)[7] > 10**6;

    alarm(0.1);
    return;
}


sub start_server {
    my $port = shift;
    my $alrm_signal = POSIX::SigSet->new(&POSIX::SIGALRM);
    my $alrm_action = POSIX::SigAction->new(
        \&new_one,
        $alrm_signal,
        &POSIX::SA_RESTART,
    );
    sigaction(SIGALRM, $alrm_action);

    $SIG{INT} = sub {
        print "GenCalc got SIGINT.Shutting down...\n";
        exit;
    };

    my $server = IO::Socket::INET->new(
        LocalPort => $port,
        Type      => SOCK_STREAM,
        ReuseAddr => 1,
        Listen    => 10) 
    or die "Can't create server on port $port : $@ $/";

    alarm(0.1);
    while(my $client = $server->accept()){
        alarm(0);
        my $msg_len;
        next if socket_read($client, $msg_len, 2) == 0;
        my $limit = unpack 'S', $msg_len;
        my $ex = get($limit);
        socket_write($client, pack('L', scalar(@$ex)));
        for (@$ex) {
            socket_write($client, pack('L/a*', $_));
        }
        close($client);
    } continue {
        alarm(0.1);
    }

}

sub request_batch {
    my ($port, $limit) = @_;

    my $socket = IO::Socket::INET->new(
        PeerAddr => 'localhost',
        PeerPort => $port,
        Proto    => 'tcp',
        Type     => SOCK_STREAM)
    or die "Can't open socket: $@ $/";

    socket_write($socket, pack('S', $limit)); 

    my $rows_cnt;
    socket_read($socket, $rows_cnt, 4); 
    $rows_cnt = unpack "L", $rows_cnt; 

    my @result;
    for (1..$rows_cnt) {
        my $len;
        socket_read($socket, $len, 4) or die("No data");
        $len = unpack "L", $len;
        my $res;
        socket_read($socket, $res, $len);
        $res = unpack "a*", $res;
        push @result, $res;
    }
    close($socket);

    return \@result;
}

sub get {
    my $limit = shift;

    safe_open(my $fh, '+<', $file_path, LOCK_EX);
    
    my @ret;

    while ($limit > 0) {
        my $expr = <$fh>;
        if (defined($expr)) {
           --$limit;
        }
        else {
           last;
        }
        push @ret, $expr;  
    }

    my @rest;

    if ($limit == 0) {
        while ((my $expr = <$fh>)) {
            push @rest, $expr;  
        }

        seek($fh, 0, SEEK_SET) or die("Cannot seek: $!");

        for my $expr (@rest) {
            print $fh $expr;
        }
    }
    else {
        seek($fh, 0, SEEK_SET) or die("Cannot seek: $!");
        truncate($fh, tell($fh)) or die ("Cannot truncate: $!");
    }

    safe_close($fh);
    return \@ret;
}

END {
    unlink $file_path;
}

1;
