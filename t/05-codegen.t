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
        like $data, qr/void packer_glPushMatrix\(Instruction \*_instruction\){/;
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
        like $data, qr/\QGLboolean packer_glIsEnabled(Instruction *_instruction, GLenum cap){\E/;
        like $data, qr/\QGLenum* _cap_ptr = (GLenum*) _ptr; *_cap_ptr++ = cap; _ptr = (void*)(_cap_ptr);\E/;
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
        like $data, qr/\Qvoid packer_glClear(Instruction *_instruction, GLbitfield mask){\E/;
        like $data, qr/\Qconst uint32_t _size = sizeof(GLbitfield);\E/;
        like $data, qr/\Qvoid* _ptr = _instruction->preallocate(_size);\E/;
        like $data, qr/\QGLbitfield* _mask_ptr = (GLbitfield*) _ptr; *_mask_ptr++ = mask; _ptr = (void*)(_mask_ptr);\E/;
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
        like $data, qr/\Qvoid packer_glTexImage2D(Instruction *_instruction, GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels){\E/;
        like $data, qr/\Qconst uint32_t _size_pixels = glTexImage2D_pixels_size( target, level, internalFormat, width, height, border, format, pixels);\E/;
        like $data, qr/\QGLenum* _format_ptr = (GLenum*) _ptr; *_format_ptr++ = format; _ptr = (void*)(_format_ptr);\E/;
        like $data, qr/\Qmemcpy(_ptr, pixels, _size_pixels);\E/;
    };

    subtest "glReadPixels" => sub {
        create_generator(
            [
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
                )
             ],
            []
        )->('packer')->(IO::Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\QGLvoid ** _data_ptr = (GLvoid **) _ptr; *_data_ptr++ = data; _ptr = (void*)(_data_ptr);\E/;
    };
};


done_testing;
