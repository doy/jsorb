#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Test::LongString;

BEGIN {
    use_ok('JSORB');
    use_ok('JSORB::Client::Compiler::Javascript');
}

{
    package Math::Simple;
    sub add { $_[0] + $_[1] }
    sub sub { $_[0] - $_[1] }
}


my $ns = JSORB::Namespace->new(
    name     => 'Math',
    elements => [
        JSORB::Interface->new(
            name       => 'Simple',
            procedures => [
                JSORB::Procedure->new(
                    name  => 'add',
                    spec  => [ 'Int' => 'Int' => 'Int' ],
                ),
                JSORB::Procedure->new(
                    name  => 'sub',
                    spec  => [ 'Int' => 'Int' => 'Int' ],
                )
            ]
        )
    ]
);
isa_ok($ns, 'JSORB::Namespace');

my $compiler = JSORB::Client::Compiler::Javascript->new;
isa_ok($compiler, 'JSORB::Client::Compiler::Javascript');

#diag $compiler->compile( namespace => $ns );

is_string(
    $compiler->compile( namespace => $ns ),
q{if (Math == undefined) var Math = function () {};
Math.Simple = function (url) {
    this._JSORB_CLIENT = new JSORB.Client ({
        base_url       : url,
        base_namespace : '/math/simple/'
    });
}
Math.Simple.prototype.add = function (arg1, arg2, callback) {
    this._JSORB_CLIENT.call(
        { method : 'add', params : [ arg1, arg2 ] },
        callback
    )
}
Math.Simple.prototype.sub = function (arg1, arg2, callback) {
    this._JSORB_CLIENT.call(
        { method : 'sub', params : [ arg1, arg2 ] },
        callback
    )
}
}, '... got the right compiled output');

is_deeply( [ $compiler->get_all_errors ], [], '... no compilation errors' );

