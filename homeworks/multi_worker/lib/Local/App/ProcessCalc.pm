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

my $results_file = './results.txt';

sub update_status {
    my ($type, $value) = @_;

    my $status;

    safe_open($status, '+<', $status_file, LOCK_EX);
    my $workers = JSON::XS::decode_json(<$status>); 
    if ($type eq 'cnt') {
        $workers->{$$}{cnt} += 1;
    }
    else {
        $workers->{$$}{status} = $value;
    }
    seek($status, 0, SEEK_SET) or die("Cannot seek: $!");
    print $status JSON::XS::encode_json($workers);
    truncate($status, tell($status)) or die("Cannot truncate: $!");
    safe_close($status);
}

sub multi_calc {
    my $fork_cnt = shift;
    my $jobs = shift;   
    my $calc_port = shift;

    my $even = int(@$jobs / $fork_cnt);
    my $rest = @$jobs - $even * $fork_cnt;

    my @job_counts = ($even)x$fork_cnt; 
    $job_counts[$_]++ for (0..$rest-1);

    my @in_jobs = @$jobs;
    my @jobs;
    push @jobs, [splice(@in_jobs, 0, $job_counts[$_])] for (0..$fork_cnt-1);
    my $workers = {};

    safe_open(my $status, '>', $status_file, LOCK_EX);

    for my $job (@jobs) {
        my $pid = fork();
        if ($pid > 0) {
            $workers->{ $pid } = {
                status => 'READY',
                count  => 0,
            };
            next;
        }
        die("Cannot fork: $!") if !defined($pid);
        close($status);

        my $socket = Local::App::Calc::connect($calc_port);

        my @results;

        update_status('status', 'PROCESS');

        for my $expr (@$job) {
            push @results, Local::App::Calc::submit($socket, $expr);
            update_status('cnt');
        }

        Local::App::Calc::disconnect($socket);

        my $results_fh;
        safe_open($results_fh, '>>', $results_file, LOCK_EX);
        print $results_fh "$_\n" for (@results);
        safe_close($results_fh);

        update_status('status', 'DONE');

        exit;
    }
    
    print $status JSON::XS::encode_json($workers);
    safe_close($status);

    while (keys %$workers) {
        my $pid = waitpid(-1, 0);
        delete $workers->{ $pid };
    }

    my @ret = ();

    my $results_fh;
    safe_open($results_fh, '<', $results_file, LOCK_SH);
    push @ret, "$_" while (<$results_fh>);
    safe_close($results_fh);

    unlink($results_file);

    return \@ret;
}


sub get_from_server {
    my $port = shift;
    my $limit = shift;

    return Local::App::GenCalc::request_batch($port, $limit);
}

1;
