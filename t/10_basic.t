use strict;
use Test::Base;

plan tests => 2 * blocks;

{
    package blosxom;
    our ( $static_entries, $header, $output );
}

my $plugin = 'conditional_get';
require $plugin;

filters {
    input    => 'yaml',
    expected => 'yaml',
};

run {
    my $block    = shift;
    my $input    = $block->input;
    my $expected = $block->expected;
    
    # Initial configuration
    local $blosxom::output = $input->{output};
    local $blosxom::header = $input->{header};
    local %ENV = %{ $input->{env} };

    $plugin->last;
    
    is_deeply $blosxom::header, $expected->{header};
    is        $blosxom::output, $expected->{output};
};

__DATA__
===
--- input
header:
    -type: text/html
env:
    REQUEST_METHOD: GET
output: foobarbaz
--- expected
header:
    -type: text/html
output: foobarbaz
===
--- input
header:
    -etag: '"foo"'
    -type: text/html
env:
    HTTP_IF_NONE_MATCH: '"foo"'
    REQUEST_METHOD: GET
output: foobarbaz
--- expected
header:
    -etag: '"foo"'
    -status: 304 Not Modified
    -type: ''
output: ''
===
--- input
header:
    -last_modified: Wed, 23 Sep 2009 13:36:33 GMT
    -type: text/html
env:
    HTTP_IF_MODIFIED_SINCE: Wed, 23 Sep 2009 13:36:33 GMT
    REQUEST_METHOD: GET
output: foobarbaz
--- expected
header:
    -last_modified: Wed, 23 Sep 2009 13:36:33 GMT
    -status: 304 Not Modified
    -type: ''
output: ''
===
--- input
header:
    -last_modified: Wed, 23 Sep 2009 13:36:33 GMT
    -type: text/html
env:
    HTTP_IF_MODIFIED_SINCE: Wed, 23 Sep 2009 13:36:32 GMT
    REQUEST_METHOD: GET
output: foobarbaz
--- expected
header:
    -last_modified: Wed, 23 Sep 2009 13:36:33 GMT
    -type: text/html
output: foobarbaz
===
--- input
header:
    -last_modified: Wed, 23 Sep 2009 13:36:33 GMT
    -type: text/html
env:
    HTTP_IF_MODIFIED_SINCE: Wed, 23 Sep 2009 13:36:33 GMT; length=2
    REQUEST_METHOD: GET
output: foobarbaz
--- expected
header:
    -last_modified: Wed, 23 Sep 2009 13:36:33 GMT
    -status: 304 Not Modified
    -type: ''
output: ''
===
--- input
header:
    -type: text/html
env:
    HTTP_IF_NONE_MATCH: Foo
    REQUEST_METHOD: POST 
output: foobarbaz
--- expected
header:
    -type: text/html
output: foobarbaz
