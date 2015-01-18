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
        create_generator([$functiondef_for->{glPushMatrix}], [])
            ->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid exec_glPushMatrix(Instruction *_i, void* executor){\E/;
        like $data, qr/\Qvoid (*my_glPushMatrix)() = (void (*)())executor;\E/;
        like $data, qr/\Q(*my_glPushMatrix)();\E/;
    };

    subtest "glClear" => sub {
        create_generator([$functiondef_for->{glClear}], [])
            ->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid exec_glClear(Instruction *_i, void* executor){\E/;
        like $data, qr/\Qvoid* my_ptr = _i->get_packed();\E/;
        like $data, qr/\Qvoid (*my_glClear)(GLbitfield) = (void (*)(GLbitfield))executor;\E/;
        like $data, qr/\Q(*my_glClear)(mask);\E/;
    };

    subtest "glVertex2iv" => sub {
        create_generator([$functiondef_for->{glVertex2iv}], [])
            ->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\QGLint * v = *_v_ptr++; my_ptr = _v_ptr;\E/;
        like $data, qr/\Qvoid (*my_glVertex2iv)(GLint *) = (void (*)(GLint *))executor;\E/;
        like $data, qr/\Q(*my_glVertex2iv)(v);\E/;
    };

    subtest "glIsEnabled" => sub {
        create_generator([$functiondef_for->{glIsEnabled}], [])
            ->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid exec_glIsEnabled(Instruction *_i, void* executor)\E/;
        like $data, qr/\QGLboolean* reply_ptr = (GLboolean*) malloc(sizeof(GLboolean));\E/;
        like $data, qr/\Q_i->store_reply((void*)reply_ptr, true);\E/;
        like $data, qr/\Q*reply_ptr = (*my_glIsEnabled)(cap);\E/;
    };

    subtest "glGetString" => sub {
        create_generator([$functiondef_for->{glGetString}], [])
            ->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst GLubyte * _reply = (*my_glGetString)(name);\E/;
        like $data, qr/\Q_i->store_reply((void*)_reply, false);\E/;
    };

    subtest "glTexImage2D" => sub {
        create_generator([$functiondef_for->{glTexImage2D}], [])
            ->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Q(*my_glTexImage2D)(target, level, internalFormat, width, height, border, format, pixels);\E/;
        unlike $data, qr/indirect reply via one of input paramterers/;
    };

    subtest "glReadPixels" => sub {
        create_generator([$functiondef_for->{glReadPixels}], [])
            ->('packed_executor')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Q(*my_glReadPixels)(x, y, width, height, format, type, data)\E/;
        like $data, qr/indirect reply via one of input paramterers/;
    };

};

done_testing;