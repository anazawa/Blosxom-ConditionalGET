use strict;
use FindBin;
use Test::More tests => 4;

{
    package blosxom;
    our ( $header, $static_entries );
}

my $plugin = 'last_modified';
require_ok "$FindBin::Bin/$plugin";
can_ok $plugin, qw/start date last/;

subtest 'static' => sub {
    local $blosxom::static_entries = 1;
    ok !$plugin->start, 'start() returns false';
};

subtest 'dynamic' => sub {
    local $blosxom::static_entries = 0;
    local $blosxom::header = { -type => 'text/html' };

    ok $plugin->start, 'start() returns true';
    $plugin->date( undef, undef, 1338204155 );
    $plugin->last;

    my $got = $blosxom::header->{-last_modified};
    my $expected = 'Mon, 28 May 2012 11:22:35 GMT';
    is $got, $expected, 'the Last-Modified header is set';
};
