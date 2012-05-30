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

    local $ENV{HTTP_IF_MODIFIED_SINCE} = $block->if_modified_since;
    local $blosxom::header->{-last_modified} = $block->last_modified;

    ok $plugin->not_modified_since  if $block->expected eq 'true';
    ok !$plugin->not_modified_since if $block->expected eq 'false';
};

__DATA__
===
--- last_modified:     Wed, 23 Sep 2009 13:36:33 GMT
--- if_modified_since: Wed, 23 Sep 2009 13:36:33 GMT
--- expected:          true
===
--- last_modified:     Wed, 23 Sep 2009 13:36:33 GMT
--- if_modified_since: Wed, 23 Sep 2009 13:36:32 GMT
--- expected:          false
===
--- last_modified:     Wed, 23 Sep 2009 13:36:33 GMT
--- if_modified_since: Wed, 23 Sep 2009 13:36:33 GMT; length=2
--- expected:          true
