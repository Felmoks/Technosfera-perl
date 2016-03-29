package Local::App::SafeIO;

use strict;
use warnings;

use Exporter 'import';
use Fcntl ':flock';
use Carp;

our @EXPORT_OK = qw(safe_open safe_close
                    LOCK_EX LOCK_SH LOCK_UN LOCK_NB
                    socket_read socket_write);
our %EXPORT_TAGS = (
    lockio => [qw(safe_open safe_close LOCK_EX LOCK_SH LOCK_UN LOCK_NB)],
);

sub safe_open {
    my ($fh, $mode, $name, $operation) = @_;

    open($_[0], $mode, $name) or die("Cannot open $name: $!");
    my $result = flock($_[0], $operation);
    close($_[0]) if !$result;
    return $result;
}

sub safe_close {
    my ($fh) = @_;

    flock($fh, LOCK_UN) or die("Cannot unlock file: $!");;
    close($fh) or die("Cannot close file: $!");;
    return 1;
}

sub socket_read {
    my ($fh, $ret, $length) = @_;
    carp("Undefined length") if !defined($length);

    my $result   = '';
    my $read_len = 0;

    while ($read_len < $length) {
        my $res;
        my $act_len = sysread($fh, $res, $length - $read_len);

        die("Sysread error: $!") if !defined($act_len);
        last if $act_len == 0;

        $result .= $res;
        $read_len += $act_len;
    }

    $_[1] = $result;
    return $read_len;
}

sub socket_write {
    my ($fh, $data) = @_;

    my $length    = length($data);
    my $write_len = 0;

    while ($write_len < $length) {
        my $send_len = $length - $write_len;
        my $res = substr($data, $write_len, $send_len);
        my $act_len = syswrite($fh, $res, $send_len);

        die("Syswrite error: $!") if !defined($act_len);

        $write_len += $act_len;
    }

    return $write_len;
}
