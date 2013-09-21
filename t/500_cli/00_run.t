use strict;
use warnings;
use utf8;
use t::Util;
use Test::More;
use Capture::Tiny ':all';
use Furl::CLI;

skip_if_offline();

my $output = capture_stdout {
    Furl::CLI->new->run(q{https://github.com/tokuhirom/Furl});
};

like $output, qr{HTTP/1\.1 200 OK};
like $output, qr{Furl};

done_testing;

