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

    subtest "dummy serializer, when no arguments glPushMatrix" => sub {
        create_generator(
            functions => [$functiondef_for->{glPushMatrix}],
            typedefs  => [],
        )->('serializer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid serializer_glPushMatrix(Instruction *_instruction, int direction){\E/;
        like $data, qr{\Q/* no arguments, no need to serialize */\E};
        like $data, qr{\Q/* no reply, no serialized result deserialization */\E};
    };

    subtest "glClear, 1 simple arg" => sub {
        create_generator(
            functions => [$functiondef_for->{glClear}],
            typedefs  => [],
        )->('serializer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid serializer_glClear(Instruction *_instruction, int direction){\E/;
        like $data, qr{\Q/* all arguments are simple, take copy from packed */\E};
        like $data, qr{\Qconst uint32_t size = _instruction->packed_size();\E};
        like $data, qr{\Qmemcpy(_instruction->serialize_allocate(size), _instruction->get_packed(), size);\E};
        like $data, qr{\Q/* no reply, no serialized result deserialization */\E};
        like $data, qr/\Q}\E/;
    };

    subtest "simple return result, glIsEnabled" => sub {
        create_generator(
            functions => [$functiondef_for->{glIsEnabled}],
            typedefs  => [],
        )->('serializer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid serializer_glIsEnabled(Instruction *_instruction, int direction){\E/;
        like $data, qr{\Q/* all arguments are simple, take copy from packed */\E};
        like $data, qr{\Q/* reply is simple, copy serialized */\E};
        like $data, qr{\Q_instruction->store_reply(_instruction->get_serialized_reply(), false);\E};
    };

    subtest "glTexImage2D (const void* ptr), no return" => sub {
        create_generator(
            functions => [$functiondef_for->{glTexImage2D}],
            typedefs  => []
        )->('serializer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid serializer_glTexImage2D(Instruction *_instruction, int direction){\E/;
        like $data, qr{\Q/* no reply, no serialized result deserialization */\E};
        like $data, qr{\Quint32_t size_for_pixels = glTexImage2D_pixels_size(target, level, internalFormat, width, height, border, format, pixels);\E};
        like $data, qr{\Quint32_t _total_size = sizeof(target)+sizeof(level)+sizeof(internalFormat)+sizeof(width)+sizeof(height)+sizeof(border)+sizeof(format)+(sizeof(uint32_t) + size_for_pixels);\E};
        like $data, qr{\Qmemcpy(_serialized_ptr, pixels, size_for_pixels); _serialized_ptr += size_for_pixels;\E};
    };

    subtest "glReadPixels (void* ptr)" => sub {
        create_generator(
            functions => [$functiondef_for->{glReadPixels}],
            typedefs  => [],
        )->('serializer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr{\Q/* overhead copy (should be ignored on deserialization) : data */\E};
        like $data, qr{\Qmemcpy(_instruction->serialize_allocate(size), _instruction->get_packed(), size);\E};
        like $data, qr{\Qchar* reply_ptr = (char*) _instruction->get_serialized_reply();\E};
        like $data, qr{\Quint32_t* size_for_data_ptr = (uint32_t*) reply_ptr;\E};
        like $data, qr{\Quint32_t size_for_data = *size_for_data_ptr++; reply_ptr = (char*) size_for_data_ptr;\E};
        like $data, qr{\Qmemcpy(data, reply_ptr, size_for_data);\E};
    };

    subtest "glVertexPointer (size/ptr parameter name)" => sub {
        create_generator(
            functions => [$functiondef_for->{glVertexPointer}],
            typedefs  => [],
        )->('serializer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr{\Qmemcpy(_serialized_ptr, ptr, size_for_ptr); _serialized_ptr += size_for_ptr;\E};
        like $data, qr{\Q/* no reply, no serialized result deserialization */\E};
    };

    subtest "glLoadTransposeMatrixd, fixed size param" => sub {
        create_generator(
            functions => [$functiondef_for->{glLoadTransposeMatrixd}],
            typedefs  => [],
        )->('serializer')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr{\Quint32_t _total_size = ( 16 * sizeof(GLdouble));\E};
        like $data, qr{\Quint32_t size_for_m = ( 16 * sizeof( GLdouble ));\E};
        like $data, qr{\Qmemcpy(_serialized_ptr, m, size_for_m );\E};
        like $data, qr{\Q_serialized_ptr += size_for_m;\E};
    };
};

done_testing;
