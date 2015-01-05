#!/usr/bin/env perl
use 5.12.0;
use strict;
use warnings;

use Getopt::Long qw(GetOptions :config no_auto_abbrev no_ignore_case);
use List::MoreUtils qw/uniq/;
use IO::String;
use IPC::Run3;
use Template::Tiny;

GetOptions(
    'r|output_role=s'   => \my $output_role,
    'h|help'            => \my $help,
);

my $show_help = $help || !$output_role;
die <<"EOF" if($show_help);
usage: $0 OPTIONS
  -r, --output_role   Output role, i.e. capture
  -h, --help          Show this message.

  $0  Copyright 2014, Ivan Baidakou, Republic of Belarus
EOF

my @headers = qw(/usr/include/GL/gl.h );

my $gather_definitions = sub {
    my ($headers) = @_;
    my %typedef_for;
    my @functions;

    for my $header (@headers) {
        run3 [(qw[clang -cc1 -ast-dump -I /usr/include/], $header)], \undef, \my $out, \my $err;
        print STDERR "error emitted for $header: $err";
        my $io = IO::String->new($out);
        while (my $line = <$io>) {
            if ($line =~ /^\|-TypedefDecl.+ (\w+) '(.+)'$/) {
                $typedef_for{$1} = $2;
            } elsif ($line =~ /^\|-FunctionDecl.+ (\w+) '(.+)'$/) {
                my $function_name = $1;
                my $return_tyoe = $2 =~ s/(.+) \(.+/$1/r;
                my @params;
                my $end_declaration = 0;
                while (!$end_declaration) {
                    $line = <$io>;
                    $end_declaration = !defined($line) || $line =~/^\|-/;
                    last if $end_declaration;
                    if ($line =~ / \|-ParmVarDecl.+ (\w+) '(.+)':'.+'$/) {
                        push @params, { name => $1, type=> $2 };
                    }
                }
                my $description = {
                    index  => scalar(@functions),
                    params => \@params,
                    result => $return_tyoe,
                    name   => $function_name,
                };
                push @functions, $description;
            }
        }
        print STDERR "found ", scalar(keys %typedef_for), " types and ",
            scalar(@functions), " functions in ", $header, "\n";
    }
    return (\%typedef_for, \@functions);
};

my $generate_capture = sub {
    my ($typedef_for, $functions, $headers) = @_;
    my $f_template = <<'END_TEMPLATE';
/* [% f.index %] */
extern "C" [% f.result %] [% f.name %] ([% signature %]) {
   pushOp([% f.index %]);

}
END_TEMPLATE

    my $typedef_template = <<'TYPEDEF_TEMPLATE_END';
typedef [% type %] [% alias %];
TYPEDEF_TEMPLATE_END
    my $tt = Template::Tiny->new;
    print '#include "generated.h"', "\n";
    #my @common_headers = qw{GL/gl.h GL/glx.h GL/glu.h};
    #print '#include "', $_ ,'"', "\n" for(@common_headers);

    my %has_type;

    my @used_types =
        uniq
        sort { $a cmp $b }
        map  { $_->{type}}
        map  { @{ $_->{params} } }
        @$functions
        ;
i
    for (@used_types) {
        $has_type{$_} = 1 if exists $typedef_for->{$_}
    }
    for (sort keys %has_type){
        $tt->process(\$typedef_template, { type => $typedef_for->{$_}, alias => $_ });
    }

    for my $f (@$functions) {
        my $signature = join(', ', map { $_->{type}.' '.$_->{name} } @{ $f->{params} });
        $tt->process(\$f_template, { f => $f, signature => $signature });
    }
};

my ($typedef_for, $functions) = $gather_definitions->(\@headers);
$generate_capture->($typedef_for, $functions, \@headers)
    if $output_role eq 'capture';
