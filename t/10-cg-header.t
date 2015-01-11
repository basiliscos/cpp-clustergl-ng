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

    subtest "glTexImage2D declartion" => sub {
        create_generator([$functiondef_for->{glTexImage2D}], [])
            ->('declaration')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid glTexImage2D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
        like $data, qr/\Qvoid packer_glTexImage2D(Instruction *_instruction, GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
        like $data, qr/\Quint32_t glTexImage2D_pixels_size(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, const GLvoid * pixels);\E/;
    };
};

done_testing;
