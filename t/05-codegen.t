use strict;
use warnings;

use IO::Scalar;
use Path::Tiny;
use Test::More;
use Test::Warnings;
use t::TestClusterGLNG qw/test_codegen/;

use ClusterGLNG::CodeGenerator qw/create_generator/;
use aliased qw/IO::Scalar/;

test_codegen {
    my ($typedef_for, $functiondef_for) = @_;

    subtest "declaration/header" => sub {

        subtest "simpe typedefs" => sub {
            create_generator([], [ $typedef_for->{GLint}, $typedef_for->{GLvoid} ])
                ->('declaration')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/typedef int GLint;/m;
            like $data, qr/typedef void GLvoid;/m;
        };

        subtest "glClear declartion" => sub {
            create_generator([$functiondef_for->{glClear}], [])
                ->('declaration')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/\Qvoid glClear(GLbitfield mask);\E/;
            like $data, qr/\Qvoid packer_glClear(Instruction *_instruction, GLbitfield mask);\E/;
        };

        subtest "glIsEnabled declartion" => sub {
            create_generator([$functiondef_for->{glIsEnabled}], [])
                ->('declaration')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/\QGLboolean glIsEnabled(GLenum cap);\E/;
            like $data, qr/\Qvoid packer_glIsEnabled(Instruction *_instruction, GLenum cap);\E/;
        };
    };

    subtest "packers" => sub {
        subtest "no packer, when no arguments glPushMatrix" => sub {
            create_generator([$functiondef_for->{glPushMatrix}], [])
                ->('packer')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/void packer_glPushMatrix\(Instruction \*_instruction\){/;
            like $data, qr/LOG.+"NO packer for packer_glPushMatrix/;
            like $data, qr/abort/;
        };

        subtest "packer, on non-void result (glIsEnabled)" => sub {
            create_generator([$functiondef_for->{glIsEnabled}], [])
                ->('packer')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/\Qvoid packer_glIsEnabled(Instruction *_instruction, GLenum cap){\E/;
            like $data, qr/\QGLenum* _cap_ptr = (GLenum*) _ptr; *_cap_ptr++ = cap; _ptr = (void*)(_cap_ptr);\E/;
        };

        subtest "glClear, 1 simple arg" => sub {
            create_generator([$functiondef_for->{glClear}], [])
                ->('packer')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/\Qvoid packer_glClear(Instruction *_instruction, GLbitfield mask){\E/;
            like $data, qr/\Qconst uint32_t _size = sizeof(GLbitfield);\E/;
            like $data, qr/\Qvoid* _ptr = _instruction->preallocate(_size);\E/;
            like $data, qr/\QGLbitfield* _mask_ptr = (GLbitfield*) _ptr; *_mask_ptr++ = mask; _ptr = (void*)(_mask_ptr);\E/;
            like $data, qr/\Q}\E/;
        };

        subtest "glTexImage2D (const void* ptr)" => sub {
            create_generator([$functiondef_for->{glTexImage2D}], [])
                ->('packer')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/\Qvoid packer_glTexImage2D(Instruction *_instruction, GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels){\E/;
            like $data, qr/\Qconst uint32_t _size_pixels = glTexImage2D_pixels_size( target, level, internalFormat, width, height, border, format, pixels);\E/;
            like $data, qr/\QGLenum* _format_ptr = (GLenum*) _ptr; *_format_ptr++ = format; _ptr = (void*)(_format_ptr);\E/;
            like $data, qr/\Qmemcpy(_ptr, pixels, _size_pixels);\E/;
        };

        subtest "glReadPixels (void* ptr)" => sub {
            create_generator([$functiondef_for->{glReadPixels}], [])
                ->('packer')->(Scalar->new(\my $data));
            ok $data;
            print "data: $data\n";
            like $data, qr/\QGLvoid ** _data_ptr = (GLvoid **) _ptr; *_data_ptr++ = data; _ptr = (void*)(_data_ptr);\E/;
        };
    };
};

done_testing;
