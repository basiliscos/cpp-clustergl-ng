#!/usr/bin/env perl
use 5.12.0;
use strict;
use warnings;

use ClusterGLNG::Parser qw/parse/;
use ClusterGLNG::CodeGenerator qw/create_generator/;
use Getopt::Long qw(GetOptions :config no_auto_abbrev no_ignore_case);
use Path::Tiny;

GetOptions(
    'a|xml_ast=s'         => \my $xml_ast,
    'f|function_filter=s' => \my $function_filter,
    'o|output_dir=s'      => \my $output_dir,
    'h|help'              => \my $help,
);

my $show_help = $help || !$xml_ast || !$function_filter || !$output_dir ;
die <<"EOF" if($show_help);
usage: $0 OPTIONS
  -a, --xml_ast          XML abstract syntax tree
  -f, --function_filter  Funtion filter, e.g. /^gl/
  -o, --output_dir       Output directory for the generated files
  -h, --help          Show this message.

  $0  Copyright 2014, Ivan Baidakou, Republic of Belarus
EOF

my $xml = path($xml_ast)->slurp;

my ($functions, $typedefs) = parse($xml, qr/$function_filter/);
print "parsing complete\n";

{
    my $generated_h = path($output_dir, 'generated.h');
    print "generating $generated_h\n";
    my $generated_h_fh = $generated_h->filehandle('>');
    print $generated_h_fh <<START;
#ifndef _GENERATED_H
#define _GENERATED_H

#include "Instruction.h"

START
    create_generator($functions, $typedefs)
        ->('declaration')->($generated_h_fh);
    print $generated_h_fh <<END;
#endif /* GENERATED_H */
END
    print "$generated_h successfully created\n";
}

{
    my $packer_c = path($output_dir, 'generated_packer.cpp');
    print "generating $packer_c\n";
    my $packer_c_fh = $packer_c->filehandle('>');
    print $packer_c_fh <<START;
#include "generated.h"
#include "common.h"
START
    create_generator($functions, $typedefs)
        ->('packer')->($packer_c_fh);
    print "$packer_c successfully created\n";
}


