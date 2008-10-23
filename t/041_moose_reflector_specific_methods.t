#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 19;
use Test::Exception;

use JSON::RPC::Common::Procedure::Call;

BEGIN {
    use_ok('JSORB');
    use_ok('JSORB::Dispatcher::Path');
    use_ok('JSORB::Reflector::Moose');
}

{
    package My::Point;
    use Moose;

    has [ 'x', 'y' ] => (
        is      => 'rw',
        isa     => 'Int',
    );
}

my $reflector = JSORB::Reflector::Moose->new(
    metaclass   => My::Point->meta,
    method_list => [
        { name => 'isa', spec => [ 'Str', 'Bool' ] },
    ],
);
isa_ok($reflector, 'JSORB::Reflector::Moose');

my $ns = $reflector->namespace;
isa_ok($ns, 'JSORB::Namespace');

my $d = JSORB::Dispatcher::Path->new_with_traits(
    traits    => [ 'JSORB::Dispatcher::Traits::WithInvocant' ],
    namespace => $ns,
);
isa_ok($d, 'JSORB::Dispatcher::Path');

my $point = My::Point->new;
isa_ok($point, 'My::Point');

{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/my/point/isa",
        params => ['My::Point'],
    );

    my $res = $d->handler($call, $point);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok($res->has_result, '... we have a result, not an error');
    ok(!$res->has_error, '... we have a result, not an error');

    ok($res->result, '... got the result we expected');
}

{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/my/point/isa",
        params => ['Foo::Bar'],
    );

    my $res = $d->handler($call, $point);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok($res->has_result, '... we have a result, not an error');
    ok(!$res->has_error, '... we have a result, not an error');

    ok(!$res->result, '... got the result we expected');
}

{
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method => "/my/point/x",
        params => [],
    );
    
    my $res = $d->handler($call, $point);
    isa_ok($res, 'JSON::RPC::Common::Procedure::Return');

    ok(!$res->has_result, '... we have a result, not an error');
    ok($res->has_error, '... we have a result, not an error');

    like($res->error->message, qr/Could not find method \/my\/point\/x/, '... got the right error');
}
