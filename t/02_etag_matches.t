use strict;
use Test::Base;

plan tests => 1 * blocks;

{
    package blosxom;
    our $header = { -type => 'text/html' };
}

my $plugin = 'conditional_get';
require $plugin;

run {
    my $block = shift;

    local $conditional_get::WEAK_COMPARISON = $block->weak_comparison;
    local $blosxom::header->{-etag} = $block->etag;
    local $ENV{HTTP_IF_NONE_MATCH} = $block->if_none_match;

    ok $plugin->etag_matches  if $block->expected eq 'true';
    ok !$plugin->etag_matches if $block->expected eq 'false';
};

__DATA__
===
--- weak_comparison: 0
--- etag: "foo"
--- if_none_match: "foo"
--- expected: true
===
--- weak_comparison: 0
--- etag: "foo"
--- if_none_match: "bar"
--- expected: false
===
--- weak_comparison: 0
--- etag: W/"foo"
--- if_none_match: "foo"
--- expected: false
===
--- weak_comparison: 0
--- etag: W/"foo"
--- if_none_match: W/"foo"
--- expected: false
===
--- weak_comparison: 0
--- etag: W/"foo"
--- if_none_match: W/"bar"
--- expected: false
===
--- weak_comparison: 1
--- etag: "foo"
--- if_none_match: "foo"
--- expected: true
===
--- weak_comparison: 1
--- etag: "foo"
--- if_none_match: "bar"
--- expected: false
===
--- weak_comparison: 1
--- etag: W/"foo"
--- if_none_match: "foo"
--- expected: true
===
--- weak_comparison: 1
--- etag: W/"foo"
--- if_none_match: W/"foo"
--- expected: true
===
--- weak_comparison: 1
--- etag: W/"foo"
--- if_none_match: W/"bar"
--- expected: false
