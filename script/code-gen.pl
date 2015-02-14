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
    my $context = {
        functions => $functions,
        typedefs  => $typedefs,
    };
    store $context, $cache_file;
    print "Stored as cache $cache_file\n";
}
elsif ($role && $cache_file && $output_dir) {
    my %context = %{ retrieve($cache_file) };
    print "$role\n";
    if ($role eq 'declaration') {
        my $file = path($output_dir, 'generated.h');
        my $last_id = scalar(@{ $context{functions} }) -1;
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<START;
#ifndef _GENERATED_H
#define _GENERATED_H

#include "Instruction.h"


#define LAST_GENERATED_ID $last_id
void cglng_fill_packed_dumpers(void *location);
void cglng_fill_packed_executors(void *location);
extern "C" const char **cglng_function_names;
extern "C" {
START
        create_generator(%context)->($role)->($fh);
        print $fh <<END;
}
#endif /* GENERATED_H */
END
        print "$file successfully created\n";
    }
    elsif ($role eq 'packer') {
        my $file = path($output_dir, 'generated_packer.cpp');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<START;
#include "generated.h"
#include "common.h"

START
        create_generator(%context)->($role)->($fh);
        print "$file successfully created\n";
    }
    elsif ($role eq 'capturer') {
        my $file = path($output_dir, 'generated_capturer.cpp');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<START;
#include "generated.h"
#include "common.h"
#include "Interceptor.h"

START
        create_generator(%context)->($role)->($fh);
        print "$file successfully created\n";
    }
    elsif ($role eq 'packed/dumper') {
        my $file = path($output_dir, 'generated_packed_dumper.cpp');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<START;
#include "generated.h"
#include "common.h"
#include "Instruction.h"
#include "Processor.h"

START
        create_generator(%context)->($role)->($fh);
        create_generator(%context)->('packed/dumper/list')->($fh);
        print "$file successfully created\n";
    }
    elsif ($role eq 'function_names') {
        my $file = path($output_dir, 'generated_function_names.cpp');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<START;
#include "generated.h"

START
        create_generator(%context)->($role)->($fh);
        print "$file successfully created\n";
    }
    elsif ($role eq 'packed/executor') {
        my $file = path($output_dir, 'generated_packed_executor.cpp');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<PACKED_EXECUTOR_START;
#include "generated.h"
#include "common.h"
#include "Instruction.h"
#include "Processor.h"

PACKED_EXECUTOR_START
        create_generator(%context)->($role)->($fh);
        create_generator(%context)->('packed/executor/list')->($fh);
        print "$file successfully created\n";
    }
    elsif ($role eq 'serializer') {
        my $file = path($output_dir, 'generated_serializer.cpp');
        print "generating $file\n";
        my $fh = $file->filehandle('>');
        print $fh <<SERIALIZER_START;
#include "generated.h"
#include "common.h"
#include "Instruction.h"
#include "Processor.h"

SERIALIZER_START
        create_generator(%context)->($role)->($fh);
        print "$file successfully created\n";
    }
    else {
        die("Role $role isn't supported");
    }
}
