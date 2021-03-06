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

    subtest "simpe typedefs" => sub {
        create_generator(
            functions => [],
            typedefs  => [ $typedef_for->{GLint}, $typedef_for->{GLvoid}],
         )->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/typedef int GLint;/m;
        like $data, qr/typedef void GLvoid;/m;
    };

    subtest "glClear declartion" => sub {
        create_generator(
            functions => [$functiondef_for->{glClear}],
            typedefs  => [],
        )->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid glClear(GLbitfield mask);\E/;
        like $data, qr/\Qvoid packer_glClear(Instruction *_instruction, GLbitfield mask);\E/;
        like $data, qr/\Qvoid exec_glClear(Instruction *_i, void* executor);\E/;
    };

    subtest "glIsEnabled declartion" => sub {
        create_generator(
            functions => [$functiondef_for->{glIsEnabled}],
            typedefs  => [],
        )->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\QGLboolean glIsEnabled(GLenum cap);\E/;
        like $data, qr/\Qvoid packer_glIsEnabled(Instruction *_instruction, GLenum cap);\E/;
    };

    subtest "glTexImage2D declartion" => sub {
        create_generator(
            functions => [$functiondef_for->{glTexImage2D}],
            typedefs  => []
        )->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid glTexImage2D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
        like $data, qr/\Qvoid packer_glTexImage2D(Instruction *_instruction, GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
        like $data, qr/\Quint32_t glTexImage2D_pixels_size(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
    };

    subtest "glTexImage2D declartion, no size" => sub {
        create_generator(
            functions => [$functiondef_for->{glTexImage2D}],
            typedefs  => [],
            skip      => {NO_serializer_glTexImage2D => 1},
        )->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid glTexImage2D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
        like $data, qr/\Qvoid packer_glTexImage2D(Instruction *_instruction, GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
        unlike $data, qr/\Quint32_t glTexImage2D_pixels_size(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
    };

    subtest "glLoadTransposeMatrixd declaration" => sub {
        create_generator(
            functions => [$functiondef_for->{glLoadTransposeMatrixd}],
            typedefs  => []
        )->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid glLoadTransposeMatrixd(const GLdouble m[16]);\E/;
        like $data, qr/\Qvoid packer_glLoadTransposeMatrixd(Instruction *_instruction, const GLdouble m[16]);\E/;
    };

    subtest "glGetPointerv declaration" => sub {
        create_generator(
            functions => [$functiondef_for->{glGetPointerv}],
            typedefs  => [],
        )->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr{\Qvoid glGetPointerv(GLenum pname, GLvoid ** params);\E};
        like $data, qr{\Qvoid packer_glGetPointerv(Instruction *_instruction, GLenum pname, GLvoid ** params);\E};
    };
};

done_testing;
