package Local::App::SafeIO;

use strict;
use warnings;

use Exporter 'import';
use Fcntl ':flock';

our @EXPORT_OK = qw(safe_open safe_close LOCK_EX LOCK_SH LOCK_UN LOCK_NB);
our %EXPORT_TAGS = (
    safeio => [qw(safe_open safe_close LOCK_EX LOCK_SH LOCK_UN LOCK_NB)],
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
