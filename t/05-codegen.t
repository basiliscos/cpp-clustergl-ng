use strict;
use warnings;

use IO::Scalar;
use Path::Tiny;
use Test::More;
use Test::Warnings;

use ClusterGLNG::CodeGenerator qw/create_generator/;
use aliased qw/IO::Scalar/;
use aliased qw/ClusterGLNG::FunctionDef/;
use aliased qw/ClusterGLNG::Parameter/;
use aliased qw/ClusterGLNG::TypeDef/;

use Log::Any::Adapter;
use Log::Dispatch;
Log::Any::Adapter->set( 'Dispatch', dispatcher => Log::Dispatch->new(
    outputs => [[ 'Screen', min_level => 'debug' ]])
);

subtest "simpe typedefs" => sub {
    create_generator([],
        [
            TypeDef->new(
                name        => 'GLint',
                declaration => 'typedef int GLint;'
            ),
            TypeDef->new(
                name        => 'GLvoid',
                declaration => 'typedef void GLvoid;',
            ),
        ],
    )->('typedefs')->(Scalar->new(\my $data));
    ok $data;
    print "data: $data\n";
    like $data, qr/typedef int GLint;/m;
    like $data, qr/typedef void GLvoid;/m;
};

subtest "packers" => sub {

    my %typedef_for = (
        GLenum => TypeDef->new(
            name        => 'GLenum',
            declaration => 'typedef unsigned int GLenum;',
        ),
        GLbitfield => TypeDef->new(
            name        => 'GLbitfield',
            declaration => 'typedef unsigned int GLbitfield;',
        ),
        GLint => TypeDef->new(
            name        => 'GLint',
            declaration => 'typedef int GLint;'
        ),
        GLsizei => TypeDef->new(
            name        => 'GLsizei',
            declaration => 'typedef int GLsizei;'
        ),
        GLvoid => TypeDef->new(
            name        => 'GLvoid',
            declaration => 'typedef void GLvoid;',
        ),
    );

    subtest "no packer, when no arguments glPushMatrix" => sub {
        create_generator(
            [
                FunctionDef->new(
                    id          => 1,
                    name        => 'glPushMatrix',
                    return_type => 'void',
                    parameters  => [],
                )
             ],
            []
        )->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/void packer_glPushMatrix\(void \*ptr\){/;
        like $data, qr/LOG.+"NO packer for packer_glPushMatrix/;
        like $data, qr/abort/;
    };

    subtest "packer, on non-void result (glIsEnabled)" => sub {
        create_generator(
            [
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
                )
             ],
            []
        )->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\QGLboolean packer_glIsEnabled(void *ptr, GLenum cap){\E/;
        like $data, qr/\QGLenum* _cap_ptr = (GLenum*) ptr; *_cap_ptr++ = cap; ptr = (void*)(_cap_ptr);\E/;
    };

    subtest "glClear, 1 simple arg" => sub {
        create_generator(
            [
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
                )
             ],
            []
        )->('packer')->(IO::Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid packer_glClear(void *ptr, GLbitfield mask){\E/;
        like $data, qr/\QGLbitfield* _mask_ptr = (GLbitfield*) ptr; *_mask_ptr++ = mask; ptr = (void*)(_mask_ptr);\E/;
        like $data, qr/\Q}\E/;
    };

    subtest "glTexImage2D" => sub {
        create_generator(
            [
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
                )
             ],
            []
        )->('packer')->(IO::Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid packer_glTexImage2D(void *ptr, GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels){\E/;
        like $data, qr/\QGLenum* _format_ptr = (GLenum*) ptr; *_format_ptr++ = format; ptr = (void*)(_format_ptr);\E/;
    };
};


done_testing;
