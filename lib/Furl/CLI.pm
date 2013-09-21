package Furl::CLI;
use strict;
use warnings;
use 5.008001;

use URI;
use Getopt::Long ();
use HTTP::Request::Common;

use Furl;

sub new {
    my $class = shift;

    bless { furl => Furl->new(timeout => 10) }, $class;
}

sub run {
    my $self = shift;

    local @ARGV = @_;

    Getopt::Long::Configure("bundling");
    Getopt::Long::GetOptions(
        'f|form' => \my $form,
    );

    my $method = shift @ARGV;
    my $url;

    if ($method =~ /^(GET|POST|PUT|DELETE|HEAD)$/) {
        $url = shift @ARGV;
    } else {
        $url = $method;
        $method = 'GET';
    }

    $url = 'http://' . $url if $url !~ qr{^https?://};

    my %query;
    my %content;
    my %header = (accept => ['*/*'], 'accept-encoding' => ['gzip, deflate, compress']);
    my $upload;

    for my $arg (@ARGV) {
        if ($arg =~ /^(.+?[^\\]):=(.+?)$/) {
            die ":= can use JSON mode" if $form;
            require JSON;
            $content{$1} = JSON->new->decode($2);
        }
        elsif ($arg =~ /^(.+?[^\\])==(.+?)$/) {
            $query{$1} = $2;
        }
        elsif ($arg =~ /^(.+)=(.+?)$/) {
            my ($key, $val) = ($1, $2);
            $key =~ s/\\=?/=/;
            $content{$key} = $val;
        }
        elsif ($arg =~ /^(.+?):(.+?)$/) {
            $header{lc $1} = [ $2 ];
        }
        elsif ($arg =~ /^(.+?)@(.+?)$/) {
            $content{$1} = [ $2 ];
            $upload = 1;
        }
        else {
            die "invalid arg: $arg";
        }
    }

    my $content;
    if (%content) {
        if ($upload) {
            my $r = POST $url, Content_Type => 'form-data', Content => [ %content ];
            $content = $r->content;
            $header{'content-type'} = [ join(';', $r->content_type) ];
        } elsif ($form) {
            my $uri = URI->new;
            $uri->query_form(\%content);
            $content = $uri->query;
            $header{'content-type'} = [ 'application/x-www-form-urlencoded; charset=utf-8' ];
        } else {
            require JSON;
            $content = JSON->new->encode(\%content);
        }
    }

    if (%query) {
        my $uri = URI->new($url);
        $uri->query_form(\%query);
        $url = $uri->as_string;
    }

    my $req = Furl::Request->new($method, $url, \%header, $content);
    my $res = $self->{furl}->request($req);

    printf "%s %d %s\n", $res->protocol, $res->code, $res->message;
    print $res->headers->as_string . "\n";
    print $res->content;
    print "\n\n";

    return 0;
}

1;

__END__

=encoding utf-8

=head1 NAME

Furl::CLI - Command Line HTTP client by Furl.

=head1 DESCRIPTION

Furl::CLI is a module.

=head1 SEE ALSO

L<Furl>
L<https://github.com/jkbr/httpie>
L<http://curl.haxx.se/>

=head1 LICENSE

Copyright (C) Kan Fushihara

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

