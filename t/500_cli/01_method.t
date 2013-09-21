use strict;
use warnings;
use utf8;
use t::Util;
use Test::More;
use Capture::Tiny ':all';
use Furl::CLI;

skip_if_offline();

my $output = capture_stdout {
    Furl::CLI->new->run(qw{PUT http://httpbin.org/put});
};

like $output, qr{HTTP/1\.1 200 OK};

done_testing;

