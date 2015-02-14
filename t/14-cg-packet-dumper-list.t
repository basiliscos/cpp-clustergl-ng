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
        )->('packed_dumper_list')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid cglng_fill_packed_dumpers(void *location) {\E/;
        like $data, qr/\QCGLNG_simple_function* ptr = (CGLNG_simple_function*)location;\E/;
        like $data, qr/\Q*ptr++ = &dump_glPushMatrix;\E/;
    };

    subtest "glIsEnabled" => sub {
        create_generator(
            functions => [$functiondef_for->{glIsEnabled}],
            typedefs  => [],
        )->('packed_dumper_list')->(Scalar->new(\my $data));
        ok $data;
        print "data: $data\n";
        like $data, qr/\Qvoid cglng_fill_packed_dumpers(void *location) {\E/;
        like $data, qr/\QCGLNG_simple_function* ptr = (CGLNG_simple_function*)location;\E/;
        like $data, qr/\Q*ptr++ =(CGLNG_simple_function)( &dump_glIsEnabled);\E/;
    };
};

done_testing;
