package Furl::CLI;
use strict;
use warnings;
use 5.008001;

use Getopt::Long ();

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
        'h|headers' => \my $headers,
    );

    my $method = shift @ARGV;
    my $url;

    if ($method =~ /^(GET|POST|PUT|DELETE|HEAD)$/) {
        $url = shift @ARGV;
    } else {
        $url = $method;
        $method = 'GET';
    }

    my $res = $self->{furl}->request(url => $url, method => $method);

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

