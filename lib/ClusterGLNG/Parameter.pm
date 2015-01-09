package ClusterGLNG::Parameter;
#Abstract: C-Function parameter representation

use Moo;

has name => (is => 'ro', required => 1);

has is_pointer => (is => 'ro', default => sub{ 0 } );

has is_const => (is => 'ro', default => sub{ 0 });

has typedef => (is => 'ro', required => 1);

sub type {
    my $self = shift;
    my $type =
        ($self->is_const ? 'const ' : '')
        . $self->typedef->name
        . ($self->is_pointer? ' *' : '');
    return $type;
}

1;
