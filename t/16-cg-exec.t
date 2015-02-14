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

    subtest "glPushMatrix" => sub {
        create_generator(
            functions => [$functiondef_for->{glPushMatrix}],
            typedefs  => [],
        )->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid exec_glPushMatrix(Instruction *_i, void* executor){\E/;
        like $data, qr/\Qvoid (*my_glPushMatrix)() = (void (*)())executor;\E/;
        like $data, qr/\Q(*my_glPushMatrix)();\E/;
    };

    subtest "glClear" => sub {
        create_generator(
            functions => [$functiondef_for->{glClear}],
            typedefs  => [],
        )->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid exec_glClear(Instruction *_i, void* executor){\E/;
        like $data, qr/\Qvoid* my_ptr = _i->get_packed();\E/;
        like $data, qr/\Qvoid (*my_glClear)(GLbitfield) = (void (*)(GLbitfield))executor;\E/;
        like $data, qr/\Q(*my_glClear)(mask);\E/;
    };

    subtest "glVertex2iv" => sub {
        create_generator(
            functions => [$functiondef_for->{glVertex2iv}],
            typedefs  => [],
        )->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\QGLint * v = *_v_ptr++; my_ptr = _v_ptr;\E/;
        like $data, qr/\Qvoid (*my_glVertex2iv)(GLint *) = (void (*)(GLint *))executor;\E/;
        like $data, qr/\Q(*my_glVertex2iv)(v);\E/;
    };

    subtest "glIsEnabled" => sub {
        create_generator(
            functions => [$functiondef_for->{glIsEnabled}],
            typedefs  => [],
        )->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid exec_glIsEnabled(Instruction *_i, void* executor)\E/;
        like $data, qr/\Qstatic GLboolean _reply;\E/;
        like $data, qr/\Q_i->store_reply((void*)&_reply, false);\E/;
        like $data, qr/\Q_reply = (*my_glIsEnabled)(cap);\E/;
    };

    subtest "glGetString" => sub {
        create_generator(
            functions => [$functiondef_for->{glGetString}],
            typedefs  => [],
        )->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst GLubyte * _reply = (*my_glGetString)(name);\E/;
        like $data, qr/\Q_i->store_reply((void*)_reply, false);\E/;
    };

    subtest "glTexImage2D" => sub {
        create_generator(
            functions => [$functiondef_for->{glTexImage2D}],
            typedefs  => [],
        )->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Q(*my_glTexImage2D)(target, level, internalFormat, width, height, border, format, pixels);\E/;
        unlike $data, qr/indirect reply via one of input paramterers/;
    };

    subtest "glReadPixels" => sub {
        create_generator(
            functions => [$functiondef_for->{glReadPixels}],
            typedefs  => [],
        )->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Q(*my_glReadPixels)(x, y, width, height, format, type, data)\E/;
        like $data, qr/indirect reply via one of input paramterers/;
    };

};

done_testing;
