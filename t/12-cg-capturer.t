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

    subtest "glPushMatrix (no packer invocation)" => sub {
        create_generator([$functiondef_for->{glPushMatrix}], [])
            ->('capturer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qextern "C" void glPushMatrix(){\E/;
        like $data, qr/\QInterceptor& my_interceptor = Interceptor::get_instance();\E/;
        like $data, qr/\QInstruction *my_instruction = my_interceptor.create_instruction(1, 0);\E/;
        like $data, qr/\Qmy_interceptor.intercept(my_instruction);\E/;
        unlike $data, qr/\Qpacker_glPushMatrix\E/;
    };

    subtest "glClear, packer invocation" => sub {
        create_generator([$functiondef_for->{glClear}], [])
            ->('capturer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qextern "C" void glClear(GLbitfield mask){\E/;
        like $data, qr/\Qpacker_glClear(my_instruction, mask);\E/;
        like $data, qr/\Qmy_interceptor.intercept(my_instruction);\E/;
    };

    subtest "glVertex2iv, packer invocation, no reply wait" => sub {
        create_generator([$functiondef_for->{glVertex2iv}], [])
            ->('capturer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid glVertex2iv(const GLint * v){\E/;
        like $data, qr/\Qpacker_glVertex2iv(my_instruction, v);\E/;
        like $data, qr/\Qmy_interceptor.intercept(my_instruction);\E/;
    };

    subtest "glIsEnabled, packer invocation, wait for result" => sub {
        create_generator([$functiondef_for->{glIsEnabled}], [])
            ->('capturer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\QGLboolean glIsEnabled(GLenum cap){\E/;
        like $data, qr/\QInstruction *my_instruction = my_interceptor.create_instruction(2, INSTRUCTION_NEED_REPLY)\E/;
        like $data, qr/\Qpacker_glIsEnabled(my_instruction, cap);\E/;
        like $data, qr/\Qmy_interceptor.intercept_with_reply(my_instruction);\E/;
        like $data, qr/\QGLboolean * reply_ptr = (GLboolean *)my_instruction->get_reply();\E/;
        like $data, qr/\Qreturn *reply_ptr;\E/;
    };

    subtest "glLoadTransposeMatrixd, submittion" => sub {
        create_generator([$functiondef_for->{glLoadTransposeMatrixd}], [])
            ->('capturer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid glLoadTransposeMatrixd(const GLdouble m[16]){\E/;
        like $data, qr/\Qpacker_glLoadTransposeMatrixd(my_instruction, m);\E/;
        like $data, qr/\Qmy_interceptor.intercept(my_instruction);\E/;
    };

    subtest "glReadPixels, submittion, wait for indirect result" => sub {
        create_generator([$functiondef_for->{glReadPixels}], [])
            ->('capturer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qmy_interceptor.intercept_with_reply(my_instruction)\E/;
        unlike $data, qr/\Qget_reply();\E/;
    };

    subtest "glGetString, waitfor result, return result as is" => sub {
        create_generator([$functiondef_for->{glGetString}], [])
            ->('capturer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst GLubyte * reply = (const GLubyte *)my_instruction->get_reply();\E/;
        like $data, qr/\Qreturn reply;\E/;
    };
};

done_testing;
