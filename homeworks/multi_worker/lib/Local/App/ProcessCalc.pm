package Local::App::ProcessCalc;

use strict;
use warnings;
use JSON::XS;
use Data::Dumper;
use Local::App::Calc;
use Local::App::SafeIO qw(:lockio socket_read socket_write);
use POSIX qw(:sys_wait_h);
use Fcntl qw(:seek);

our $VERSION = '1.0';
our $status_file = './calc_status.txt';

sub update_status {
    my ($type, $value) = @_;

    my $status_fh;
    my $workers;

    safe_open($status_fh, '+<', $status_file, LOCK_EX);
    $workers = JSON::XS::decode_json(<$status_fh>);

    if ($type eq 'cnt') {
        $workers->{$$}{cnt} += 1;
    }
    else {
        $workers->{$$}{status} = $value;
        $workers->{$$}{cnt} = 0 if $value eq 'READY';
    }

    seek($status_fh, 0, SEEK_SET) or die("Cannot seek: $!");
    print $status_fh JSON::XS::encode_json($workers);
    truncate($status_fh, tell($status_fh)) or die("Cannot truncate: $!");

    safe_close($status_fh);
}

sub split_jobs {
    my ($jobs, $fork_cnt) = @_;

    my $even = int(@$jobs / $fork_cnt);
    my $rest = @$jobs - $even * $fork_cnt;

    my @job_counts = ($even)x$fork_cnt; 
    $job_counts[$_]++ for (0..$rest-1);

    my @in_jobs = @$jobs;
    my @jobs;
    push @jobs, [splice(@in_jobs, 0, $job_counts[$_])] for (0..$fork_cnt-1);

    return \@jobs;
}

sub dump_results {
    my ($results) = @_;

    open(my $results_fh, '>', "results_$$.txt");
    print $results_fh "$_\n" for (@$results);
    close($results_fh);
}

sub collect_results {
    my ($workers, $results) = @_;
    
    while (my $pid = waitpid(-1, WNOHANG)) {
        last if $pid == -1;
        my $results_file = delete $workers->{$pid};
        if (WIFEXITED($?)) {
            if (WEXITSTATUS($?) != 0) {
                kill 'INT', (keys %$workers);
                next;
            }
            open(my $worker_results, '<', $results_file);
            push @$results, $_ while (<$worker_results>);
            close($worker_results);
        }
        elsif (WIFSIGNALED($?)) {
            kill 'INT', (keys %$workers);
            my $sig = WTERMSIG($?);
            print "WORKER $pid CAUGHT $sig\n";
        }
    } continue {
        unlink "results_$pid.txt" if $pid > 0;
    }
}

sub multi_calc {
    my $fork_cnt = shift;
    my $jobs = shift;   
    my $calc_port = shift;

    my $splitted_jobs = split_jobs($jobs, $fork_cnt);

    my $workers = {};
    my $ret = [];

    $SIG{CHLD} = sub {
        collect_results($workers, $ret)
    };

    $SIG{INT} = sub {
        kill 'INT', (keys %$workers);
        die "ProcessCalc master got SIGINT.Shutting down...\n";
    };

    my $status_fh;
    safe_open($status_fh, '>', $status_file, LOCK_EX);
    print $status_fh JSON::XS::encode_json({});
    safe_close($status_fh);

    for my $job (@$splitted_jobs) {
        my $pid = fork();
        if ($pid > 0) {
            $workers->{ $pid } = "results_$pid.txt";
            next;
        }
        die("Cannot fork: $!") if !defined($pid);

        $SIG{INT} = "DEFAULT";

        update_status('status', 'READY');

        my $socket = Local::App::Calc::connect($calc_port);

        my @results;

        update_status('status', 'PROCESS');

        for my $expr (@$job) {
            push @results, Local::App::Calc::submit($socket, $expr);
            update_status('cnt');
        }

        Local::App::Calc::disconnect($socket);

        dump_results(\@results);

        update_status('status', 'DONE');

        exit;
    }

    while (keys %$workers) {
        #Doing something while workers are active
        #print Dumper $workers;
        sleep(5);
    }


    return $ret;
}


sub get_from_server {
    my $port = shift;
    my $limit = shift;

    return Local::App::GenCalc::request_batch($port, $limit);
}

my $master_pid = $$;

END {
    unlink $status_file if $$ eq $master_pid;
}

1;
