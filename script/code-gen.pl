#!/usr/bin/env perl
use 5.12.0;
use strict;
use warnings;

use ClusterGLNG::Parser qw/parse/;
use Path::Tiny;

my $xml = path($ARGV[0])->slurp;

my ($functions, $typedefs) = parse($xml, qr/$ARGV[1]/);

print "OK\n";
