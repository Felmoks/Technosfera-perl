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
    my $workers;
    if (-e $status_file) {
        safe_open($status, '+<', $status_file, LOCK_EX);
        $workers = JSON::XS::decode_json(<$status>); 
    }
    else {
        safe_open($status, '+>', $status_file, LOCK_EX);
        $workers = {};
    }
    if ($type eq 'cnt') {
        $workers->{$$}{cnt} += 1;
    }
    else {
        $workers->{$$}{status} = $value;
        $workers->{$$}{cnt} = 0 if $value eq 'READY';
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
    my @workers = ();

    for my $job (@jobs) {
        my $pid = fork();
        if ($pid > 0) {
            push @workers, $pid;
            next;
        }
        die("Cannot fork: $!") if !defined($pid);

        update_status('status', 'READY');

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

    while (@workers) {
        my $pid = waitpid(-1, 0);
        @workers = grep { $pid ne $_ } @workers;
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
