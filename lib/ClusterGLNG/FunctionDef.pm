package ClusterGLNG::FunctionDef;
#Abstract: C-Function declaration representation

use Moo;

# "id" to quickl lookup in function table
has id => (is => 'ro', required => 1);

# function name
has name => (is => 'ro', required => 1);

# function return type
has return_type => (is => 'ro', required => 1);

has parameters => (is => 'ro', default => sub { [] });

1;
