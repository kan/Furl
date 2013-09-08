use strict;
use warnings;
use utf8;
use Test::More;
use Capture::Tiny ':all';
use Furl::CLI;

my $output = capture_stdout {
    Furl::CLI->new->run(qw{PUT http://httpbin.org/put});
};

like $output, qr{HTTP/1\.1 200 OK};

done_testing;

