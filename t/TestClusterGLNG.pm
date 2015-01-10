package t::TestClusterGLNG;

use strict;
use warnings;

use parent qw/Exporter/;
our @EXPORT_OK = qw/test_codegen/;

use aliased qw/ClusterGLNG::FunctionDef/;
use aliased qw/ClusterGLNG::Parameter/;
use aliased qw/ClusterGLNG::TypeDef/;

my %typedef_for = (
    map { $_->name => $_ } (
        TypeDef->new(
            name        => 'GLenum',
            declaration => 'typedef unsigned int GLenum;',
        ),
        TypeDef->new(
            name        => 'GLbitfield',
            declaration => 'typedef unsigned int GLbitfield;',
        ),
        TypeDef->new(
            name        => 'GLint',
            declaration => 'typedef int GLint;'
        ),
        TypeDef->new(
            name        => 'GLsizei',
            declaration => 'typedef int GLsizei;'
        ),
        TypeDef->new(
            name        => 'GLvoid',
            declaration => 'typedef void GLvoid;',
        ),
    )
);

my %function_for = (
    map { $_->name => $_ } (
        FunctionDef->new(
            id          => 1,
            name        => 'glPushMatrix',
            return_type => 'void',
            parameters  => [],
        ),
        FunctionDef->new(
            id          => 2,
            name        => 'glIsEnabled',
            return_type => 'GLboolean',
            parameters  => [
                Parameter->new(
                    name    => 'cap',
                    typedef => $typedef_for{GLenum},
                )
            ],
        ),
        FunctionDef->new(
            id          => 1,
            name        => 'glClear',
            return_type => 'void',
            parameters  => [
                Parameter->new(
                    name    => 'mask',
                    typedef => $typedef_for{GLbitfield},
                )
            ],
        ),
        FunctionDef->new(
            id          => 3,
            name        => 'glTexImage2D',
            return_type => 'void',
            parameters  => [
                Parameter->new(name => 'target', typedef => $typedef_for{GLenum} ),
                Parameter->new(name => 'level', typedef => $typedef_for{GLint} ),
                Parameter->new(name => 'internalFormat', typedef => $typedef_for{GLint} ),
                Parameter->new(name => 'width', typedef => $typedef_for{GLsizei} ),
                Parameter->new(name => 'height', typedef => $typedef_for{GLsizei} ),
                Parameter->new(name => 'border', typedef => $typedef_for{GLint} ),
                Parameter->new(name => 'format', typedef => $typedef_for{GLenum}),
                Parameter->new(name => 'pixels', typedef => $typedef_for{GLvoid}, is_pointer => 1, is_const => 1),
            ],
        ),
        FunctionDef->new(
            id          => 4,
            name        => 'glReadPixels',
            return_type => 'void',
            parameters  => [
                Parameter->new(name => 'x', typedef => $typedef_for{GLint} ),
                Parameter->new(name => 'y', typedef => $typedef_for{GLint} ),
                Parameter->new(name => 'width', typedef => $typedef_for{GLsizei} ),
                Parameter->new(name => 'height', typedef => $typedef_for{GLsizei} ),
                Parameter->new(name => 'format', typedef => $typedef_for{GLenum}),
                Parameter->new(name => 'type', typedef => $typedef_for{GLenum}),
                Parameter->new(name => 'data', typedef => $typedef_for{GLvoid}, is_pointer => 1),
            ],
        ),
    )
);

sub test_codegen(&) {
    my $callback = shift;
    $callback->(\%typedef_for, \%function_for);
};

1;
