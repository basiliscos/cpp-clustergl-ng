use strict;
use warnings;

use Path::Tiny;
use Test::More;
use Test::Warnings;

use ClusterGLNG::Parser qw/parse/;

my $xml = path(qw/t data sample.xml/)->slurp;
my ($functions, $typedefs) = parse($xml, qr/^gl/);

is scalar(@$functions), 5, "has correct number of functions";
is scalar(@$typedefs), 5, "has correct number of typedefs";

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
            name       => $_->name,
            pointer    => $_->pointer // '',
            is_const   => $_->is_const,
            typedef    => $_->typedef->name,
        }
    } @$params;
    is_deeply \@simplified_params, [
        {
            name       => 'target',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLenum',
        },
        {
            name       => 'level',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLint',
        },
        {
            name       => 'internalFormat',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLint',
        },
        {
            name       => 'width',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLsizei',
        },
        {
            name       => 'height',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLsizei',
        },
        {
            name       => 'border',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLint',
        },
        {
            name       => 'format',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLenum',
        },
        {
            name       => 'type',
            pointer    => '',
            is_const   => '',
            typedef    => 'GLenum',
        },
        {
            name       => 'pixels',
            pointer    => '*',
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
    is $params->[0]->fixed_size, 0;
};

subtest "glLoadTransposeMatrixd function definition" => sub {
    my ($f) = grep { $_->name eq 'glLoadTransposeMatrixd' } @$functions;
    ok $f;
    is $f->id, 3;
    is $f->name, 'glLoadTransposeMatrixd', "name is correct";
    is $f->return_type, 'void', "return type is correct";

    my $params = $f->parameters;
    is scalar(@$params), 1, "has 1 parameter";
    my $p = $params->[0];
    is $p->name, 'm';
    ok $p->is_const;
    is $p->fixed_size, 16;
};

subtest "glGetPointerv function definition" => sub {
    my ($f) = grep { $_->name eq 'glGetPointerv' } @$functions;
    ok $f;
    is $f->id, 4;
    is $f->name, 'glGetPointerv', "name is correct";
    is $f->return_type, 'void', "return type is correct";

    my $params = $f->parameters;
    is scalar(@$params), 2, "has 2 parameters";
    my $p = $params->[0];
    is $p->name, 'pname';
    my $p2 = $params->[1];
    is $p2->name, 'params';
    is $p2->pointer, '**';
};

done_testing;
