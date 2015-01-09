package ClusterGLNG::TypeDef;
#Abstract: C TypeDef declaration representation

use Moo;

has 'name'        => (is => 'ro', required => 1);
has 'declaration' => (is => 'ro', required => 1);

1;
