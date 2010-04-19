package JSORB::Resource;
use Moose;
use Resource::Pack;

extends 'Resource::Pack::Resource';

has '+name' => (default => 'jsorb');

sub BUILD {
    my $self = shift;

    resource $self => as {
        install_from(Path::Class::File->new(__FILE__)->parent
                                                     ->parent
                                                     ->subdir('JS'));
        file js => 'JSORB.js';
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
no Resource::Pack;

1;
