use strict;
use Test::More tests => 4;

# Filenames of Blosxom plugins lack an extension '.pm'
*Test::More::_is_module_name = sub { 0 };

{
    package blosxom;
    our $static_entries;
}

my $plugin = 'conditional_get';
require_ok $plugin;
can_ok $plugin, qw(start last);

subtest 'static' => sub {
    local $blosxom::static_entries = 1;
    ok !$plugin->start, 'start() should return false';
};

subtest 'dynamic' => sub {
    local $blosxom::static_entries = 0;
    ok $plugin->start, 'start() should return true';
};
