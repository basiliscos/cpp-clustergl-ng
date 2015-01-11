use strict;
use warnings;

use Path::Tiny;
use Test::More;
use Test::Warnings;

use ClusterGLNG::Parser qw/parse/;

my $xml = path(qw/t data sample.xml/)->slurp;
my ($functions, $typedefs) = parse($xml, qr/^gl/);

is scalar(@$functions), 3, "has 2 functions";
is scalar(@$typedefs), 4, "has 4 typedefs";

subtest "GLint typedef" => sub {
    my ($gl_typedef) = grep { $_->name eq 'GLint' } @$typedefs;
    ok $gl_typedef, "has GLint typedef";
    is $gl_typedef->declaration,
        "typedef int GLint;",
        "has GLint declaration";
};

my $unused_type = grep { $_->name eq 'UnusedType' } @$typedefs;
ok !$unused_type, "no UnusedType";

subtest "glTexImage2D function definition" => sub {
    my ($f) = grep { $_->name eq 'glTexImage2D' } @$functions;
    ok $f;
    is $f->id, 0;
    is $f->name, 'glTexImage2D', "name is correct";
    is $f->return_type, 'void', "return type is correct";

    my $params = $f->parameters;
    is scalar(@$params), 9, "has 9 parameters";
    my @simplified_params = map {
        {
            name => $_->name,
            is_pointer => $_->is_pointer,
            is_const   => $_->is_const,
            typedef    => $_->typedef->name,
        }
    } @$params;
    is_deeply \@simplified_params, [
        {
            name       => 'target',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLenum',
        },
        {
            name       => 'level',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLint',
        },
        {
            name       => 'internalFormat',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLint',
        },
        {
            name       => 'width',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLsizei',
        },
        {
            name       => 'height',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLsizei',
        },
        {
            name       => 'border',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLint',
        },
        {
            name       => 'format',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLenum',
        },
        {
            name       => 'type',
            is_pointer => '',
            is_const   => '',
            typedef    => 'GLenum',
        },
        {
            name       => 'pixels',
            is_pointer => 1,
            is_const   => 1,
            typedef    => 'GLvoid',
        },
    ];
};

subtest "glPopAttrib function definition" => sub {
    my ($f) = grep { $_->name eq 'glPopAttrib' } @$functions;
    ok $f;
    is $f->id, 1;
    is $f->name, 'glPopAttrib', "name is correct";
    is $f->return_type, 'void', "return type is correct";

    my $params = $f->parameters;
    is scalar(@$params), 0, "has no parameters";
};

subtest "glGetString function definition" => sub {
    my ($f) = grep { $_->name eq 'glGetString' } @$functions;
    ok $f;
    is $f->id, 2;
    is $f->name, 'glGetString', "name is correct";
    is $f->return_type, 'const GLubyte *', "return type is correct";

    my $params = $f->parameters;
    is scalar(@$params), 1, "has 1 parameter";
};

done_testing;
