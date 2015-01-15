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
            ->('packed_dumper')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid dump_glPushMatrix(Instruction *_i){\E/;
        like $data, qr/\Qconst char* prefix = "";\E/;
        like $data, qr/\QLOG("%s glPushMatrix()\n", prefix );\E/;
    };

    subtest "glIsEnabled" => sub {
        create_generator([$functiondef_for->{glIsEnabled}], [])
            ->('packed_dumper')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid dump_glIsEnabled(Instruction *_i, int direction){\E/;
        like $data, qr/\Qconst char* prefix = direction == DIRECTION_FORWARD ? "[>>]" : "[<<]";\E/;
        like $data, qr/\Qvoid* my_ptr = _i->get_packed();\E/;
        like $data, qr/\QGLenum* _cap_ptr = (GLenum*) my_ptr;\E/;
        like $data, qr/\QGLenum cap = *_cap_ptr++; my_ptr = _cap_ptr;\E/;
        like $data, qr/\QLOG("%s glIsEnabled(cap = %u)\n", prefix, cap );\E/;
    };

    subtest "glClear" => sub {
        create_generator([$functiondef_for->{glClear}], [])
            ->('packed_dumper')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst char* prefix = "";\E/;
        like $data, qr/\QGLbitfield mask = *_mask_ptr++; my_ptr = _mask_ptr;\E/;
        like $data, qr/\QLOG("%s glClear(mask = %u)\n", prefix, mask );\E/;
    };

    subtest "glTexImage2D" => sub {
        create_generator([$functiondef_for->{glTexImage2D}], [])
            ->('packed_dumper')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst char* prefix = "";\E/;
        like $data, qr/\QLOG("%s glTexImage2D(target = %u, level = %d, internalFormat = %d, width = %d, height = %d, border = %d, format = %u)\n", prefix, target, level, internalFormat, width, height, border, format );\E/;
    };

    subtest "glReadPixels" => sub {
        create_generator([$functiondef_for->{glReadPixels}], [])
            ->('packed_dumper')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst char* prefix = direction == DIRECTION_FORWARD ? "[>>]" : "[<<]";\E/;
        like $data, qr/\QLOG("%s glReadPixels(x = %d, y = %d, width = %d, height = %d, format = %u, type = %u)\n", prefix, x, y, width, height, format, type );\E/;
    };

    subtest "glLoadTransposeMatrixd" => sub {
        create_generator([$functiondef_for->{glLoadTransposeMatrixd}], [])
            ->('packed_dumper')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qconst char* prefix = "";\E/;
        like $data, qr/\QLOG("%s glLoadTransposeMatrixd()\n", prefix );\E/;
    };
};

done_testing;
