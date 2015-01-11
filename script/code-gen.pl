#!/usr/bin/env perl
use 5.12.0;
use strict;
use warnings;

use ClusterGLNG::Parser qw/parse/;
use ClusterGLNG::CodeGenerator qw/create_generator/;
use Getopt::Long qw(GetOptions :config no_auto_abbrev no_ignore_case);
use Path::Tiny;
use Storable;

GetOptions(
    'a|xml_ast=s'         => \my $xml_ast,
    'c|cache_file=s'      => \my $cache_file,
    'f|function_filter=s' => \my $function_filter,
    'r|role=s'            => \my $role,
    'o|output_dir=s'      => \my $output_dir,
    'h|help'              => \my $help,
);

my $show_help = $help || ($xml_ast && !($cache_file && $function_filter))
    || (!$xml_ast && $cache_file && !($output_dir && $role));
die <<"EOF" if($show_help);
usage: $0 OPTIONS
  -a, --xml_ast          XML abstract syntax tree
  -c, --cache_file       Cache file
  -f, --function_filter  Funtion filter, e.g. /^gl/
  -o, --output_dir       Output directory for the generated files
  -r, --role             Role, i.e. declaration, packer, ...
  -h, --help             Show this message.

  $0  Copyright 2014, Ivan Baidakou, Republic of Belarus
EOF

if ($xml_ast && $cache_file) {
    my $xml = path($xml_ast)->slurp;
    my ($functions, $typedefs) = parse($xml, qr/$function_filter/);
    print "parsing complete\n";
    store [$functions, $typedefs], $cache_file;
    print "Stored as cache $cache_file\n";
}
elsif ($role && $cache_file && $output_dir) {
    my ($functions, $typedefs) = @{ retrieve($cache_file) };
    print "$role\n";
    if ($role eq 'declaration') {
        my $file = path($output_dir, 'generated.h');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<START;
#ifndef _GENERATED_H
#define _GENERATED_H

#include "Instruction.h"

START
        create_generator($functions, $typedefs)->('declaration')->($fh);
        print $fh <<END;
#endif /* GENERATED_H */
END
        print "$file successfully created\n";
    }
    elsif ($role eq 'packer') {
        my $file = path($output_dir, 'generated_packer.cpp');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        my $last_id = scalar($@functions) -1;
        print $fh <<START;
#include "generated.h"
#include "common.h"

#define LAST_GENERATED_ID = $last_id;
START
        create_generator($functions, $typedefs)->('packer')->($fh);
        print "$file successfully created\n";
    }
    else {
        die("Role $role isn't supported");
    }
}
