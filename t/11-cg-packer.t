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
        like $data, qr/\Qconst uint32_t _size = sizeof(GLenum*);\E/;
        like $data, qr/\Qvoid* _ptr = _instruction->pack_allocate(_size);\E/;
        like $data, qr/\QGLenum* _cap_ptr = (GLenum*) _ptr; *_cap_ptr++ = cap; _ptr = (void*)(_cap_ptr);\E/;
    };

    subtest "glClear, 1 simple arg" => sub {
        create_generator([$functiondef_for->{glClear}], [])
            ->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid packer_glClear(Instruction *_instruction, GLbitfield mask){\E/;
        like $data, qr/\Qconst uint32_t _size = sizeof(GLbitfield*);\E/;
        like $data, qr/\QGLbitfield* _mask_ptr = (GLbitfield*) _ptr; *_mask_ptr++ = mask; _ptr = (void*)(_mask_ptr);\E/;
        like $data, qr/\Q}\E/;
    };

    subtest "glTexImage2D (const void* ptr)" => sub {
        create_generator([$functiondef_for->{glTexImage2D}], [])
            ->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid packer_glTexImage2D(Instruction *_instruction, GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels){\E/;
        like $data, qr/\Qconst uint32_t _size = sizeof(GLenum*)+sizeof(GLint*)+sizeof(GLint*)+sizeof(GLsizei*)+sizeof(GLsizei*)+sizeof(GLint*)+sizeof(GLenum*)+sizeof(GLvoid **)\E/;
        like $data, qr/\QGLenum* _format_ptr = (GLenum*) _ptr; *_format_ptr++ = format; _ptr = (void*)(_format_ptr);\E/;
    };

    subtest "glReadPixels (void* ptr)" => sub {
        create_generator([$functiondef_for->{glReadPixels}], [])
            ->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\QGLvoid ** _data_ptr = (GLvoid **) _ptr; *_data_ptr++ = data; _ptr = (void*)(_data_ptr);\E/;
    };

    subtest "glVertexPointer (size/ptr parameter name)" => sub {
        create_generator([$functiondef_for->{glVertexPointer}], [])
            ->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst uint32_t _size = sizeof(GLint*)+sizeof(GLenum*)+sizeof(GLsizei*)+sizeof(GLvoid **);\E/;
        like $data, qr/\QGLint* _size_ptr = (GLint*) _ptr; *_size_ptr++ = size; _ptr = (void*)(_size_ptr);\E/;
        like $data, qr/\Qconst GLvoid ** _ptr_ptr = (const GLvoid **) _ptr; *_ptr_ptr++ = ptr; _ptr = (void*)(_ptr_ptr);\E/;
    };

    subtest "glLoadTransposeMatrixd, fixed size param" => sub {
        create_generator([$functiondef_for->{glLoadTransposeMatrixd}], [])
            ->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid packer_glLoadTransposeMatrixd(Instruction *_instruction, const GLdouble m[16]){\E/;
        like $data, qr/\Qconst uint32_t _size = sizeof(GLdouble**);\E/;
        like $data, qr/\Qconst GLdouble** _m_ptr = (const GLdouble**) _ptr; *_m_ptr++ = m; _ptr = (void*)(_m_ptr);\E/;
    };

    subtest "glGetPointerv, ** pointer" => sub {
        create_generator([$functiondef_for->{glGetPointerv}], [])
            ->('packer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr|\Qvoid packer_glGetPointerv(Instruction *_instruction, GLenum pname, GLvoid ** params){\E|;
        like $data, qr|\Qconst uint32_t _size = sizeof(GLenum*)+sizeof(GLvoid ***);\E|;
        like $data, qr|\Q GLvoid *** _params_ptr = (GLvoid ***) _ptr; *_params_ptr++ = params; _ptr = (void*)(_params_ptr);\E|;
    };
};

done_testing;
