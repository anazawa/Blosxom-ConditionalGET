use strict;
use FindBin;
use Test::More tests => 4;

{
    package blosxom;
    our ( $header, $static_entries, $output );
}

my $plugin = 'etag';
require_ok "$FindBin::Bin/$plugin";
can_ok $plugin, qw/start date last/;

subtest 'static' => sub {
    local $blosxom::static_entries = 1;
    ok !$plugin->start, 'start() returns false';
};

subtest 'dynamic' => sub {
    local $blosxom::static_entries = 0;
    local $blosxom::output = 'foobarbaz';
    local $blosxom::header = { -type => 'text/html' };

    ok $plugin->start, 'start() returns true';
    $plugin->last;

    my $got = $blosxom::header->{-etag};
    my $expected = '"6df23dc03f9b54cc38a0fc1483df6e21"';
    is $got, $expected, 'the ETag header is set';

    $plugin->date( undef, undef, 1338204154 );
    $plugin->last;

    $got = $blosxom::header->{-etag};
    $expected = '"4fc35ffa-9"';
    is $got, $expected, 'the ETag header is set';

    $plugin->date( undef, undef, time );
    sleep 1;
    $plugin->last;

    $got = $blosxom::header->{-etag};
    $expected = qr{^W/"\w+-9"$};
    like $got, $expected, 'the ETag header is set';
};
