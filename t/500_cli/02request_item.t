use strict;
use warnings;
use utf8;
use t::Util;
use Test::More;
use Capture::Tiny ':all';
use Furl::CLI;

skip_if_offline();
eval { require JSON };
plan skip_all => "skip at JSON.pm not installed" if $@; 

sub test_cli_call {
    my @args = @_;

    my $output = capture_stdout {
        Furl::CLI->new->run(@args);
    };

    return JSON->new->decode($output);
}

subtest "query_param" => sub {
    my $r = test_cli_call(qw{-b GET http://httpbin.org/get foo==bar});

    is $r->{args}->{foo}, 'bar', 'setup query_params';
};

subtest "content(json)" => sub {
    my $r = test_cli_call(qw{-b POST http://httpbin.org/post foo=bar});

    is $r->{json}->{foo}, 'bar', 'setup content JSON';

    my $r2 = test_cli_call(qw{-b POST http://httpbin.org/post foo\==bar});

    is $r2->{json}->{'foo='}, 'bar', 'test escape char';

    my $r3 = test_cli_call(qw{-b POST http://httpbin.org/post}, 'foo:=[1,2,3]');

    is_deeply $r3->{json}->{'foo'}, [1,2,3], 'setup content raw JSON';
};

subtest "content(form)" => sub {
    my $r = test_cli_call(qw{-b -f POST http://httpbin.org/post foo=bar});

    is $r->{form}->{foo}, 'bar', 'setup content form-data';
};

subtest "header" => sub {
    my $r = test_cli_call(qw{-b GET http://httpbin.org/get X-Foo:Bar});

    is $r->{headers}->{'X-Foo'}, 'Bar', 'setup header';
};

subtest "file upload" => sub {
    my $r = test_cli_call(qw{-b POST http://httpbin.org/post foo@LICENSE});

    like $r->{files}->{foo}, qr/LICENSE/, 'upload file';
};

done_testing;

