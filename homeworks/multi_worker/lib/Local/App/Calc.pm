package Local::App::Calc;

use strict;
use warnings;

use IO::Socket;
use Local::App::SafeIO qw(socket_read socket_write);
use Local::App::Calc::Parser    qw(rpn);
use Local::App::Calc::Evaluator qw(evaluate);

#Определение обрабатываемых сигналов
sub start_server {
    # На вход получаем порт который будет слушать сервер занимающийся расчетами примеров
    my $port = shift;
    
    # Создание сервера и обработка входящих соединений, форки не нужны 
    # Входящее и исходящее сообщение: int 4 byte + string
    # На каждое подключение отдельный процесс. В рамках одного соединения может быть передано несколько примеров
    $SIG{CHLD} = 'IGNORE';
    $SIG{INT} = sub {
        print "Calc got SIGINT.Shutting down...\n";
        exit;
    };
    my $server = IO::Socket::INET->new(
        LocalPort => $port,
        Type      => SOCK_STREAM,
        ReuseAddr => 1,
        Listen    => 10) 
    or die "Can't create server on port $port : $@ $/";

    while(my $client = $server->accept()){
        my $msg;
        if (my $pid = fork()) {
            close($client);
        }
        else {
            die("Cannot fork: $!") if !defined($pid);
            while (socket_read($client, $msg, 4)) {
                my $length = unpack 'L', $msg;
                my $task;
                socket_read($client, $task, $length);
                my $result = calculate($task);
                socket_write($client, pack('L/a*', $result));
            }
            close($client);
            exit;
        }
    }

    print "EXIT: $!\n";
}

sub connect {
    my ($port) = @_;

    my $socket = IO::Socket::INET->new(
        PeerAddr => 'localhost',
        PeerPort => $port,
        Proto    => 'tcp',
        Type     => SOCK_STREAM)
    or die "Can't open socket: $@ $/";

    return $socket;
}

sub disconnect {
    my ($socket) = @_;

    close($socket) or die("Cannot close socket: $!");
}

sub submit {
    my ($socket, $expr) = @_;

    my $packed = pack "L/a*", $expr;
    socket_write($socket, $packed);

    my $length;
    socket_read($socket, $length, 4); 
    $length = unpack "L", $length; 

    my $answer; 
    socket_read($socket, $answer, $length); 
    $answer = unpack "a*", $answer; 

    return $answer;
}

sub calculate {
    my $ex = shift;
    # На вход получаем пример, который надо обработать, на выход возвращаем результат
    
    my $result;

    eval {
        $result = evaluate(rpn($ex));
    } or do {
        $result = 'ERROR';
    };

    return $result;
}

1;
