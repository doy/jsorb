package JSORB::Resource;
use Moose;
use Resource::Pack;

use Resource::Pack::jQuery;
use Resource::Pack::JSON;

extends 'Resource::Pack::Resource';

has '+name' => (default => 'jsorb');

sub BUILD {
    my $self = shift;

    resource $self => as {
        install_from(Path::Class::File->new(__FILE__)->parent
                                                     ->parent
                                                     ->subdir('JS'));
        resource(Resource::Pack::jQuery->new(use_bundled => 1));
        resource(Resource::Pack::JSON->new(use_bundled => 1));
        file js => (
            file => 'JSORB.js',
            dependencies => {
                jquery => depends_on('jquery/js'),
                json   => depends_on('json/js'),
            },
        );
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Resource::Pack;

1;
