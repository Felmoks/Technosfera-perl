#!/usr/bin/perl
 
use strict;
use warnings;
use Test::More tests => 15;

use Local::App::SafeIO qw(safe_open safe_close);
use Fcntl ':flock';

my ($fh, $fh1, $fh2);

ok(safe_open($fh, '>', 'test.file', LOCK_EX));
ok(safe_close($fh));

ok(safe_open($fh1, '>', 'test.file', LOCK_EX));
ok(!safe_open($fh2, '>', 'test.file', LOCK_EX | LOCK_NB));
ok(!safe_open($fh2, '>', 'test.file', LOCK_SH | LOCK_NB));
ok(safe_close($fh1));
ok(safe_open($fh2, '>', 'test.file', LOCK_EX));
ok(safe_close($fh2));
ok(safe_open($fh2, '>', 'test.file', LOCK_SH));
ok(safe_close($fh2));

ok(safe_open($fh1, '>', 'test.file', LOCK_SH));
ok(safe_open($fh2, '>', 'test.file', LOCK_SH));
ok(!safe_open($fh, '>', 'test.file', LOCK_EX | LOCK_NB));
ok(safe_close($fh2));
ok(safe_close($fh1));
