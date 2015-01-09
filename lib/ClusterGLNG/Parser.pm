package ClusterGLNG::Parser;
#Abstract: Transforms cscan xml into structures
use strict;
use warnings;

use ClusterGLNG::FunctionDef;
use ClusterGLNG::Parameter;
use ClusterGLNG::TypeDef;

use XML::LibXML;
use XML::LibXML::XPathContext;

use parent qw/Exporter/;
our @EXPORT_OK = qw/parse/;

sub parse {
    my ($xml, $fname_filter) = @_;
    my $dom = XML::LibXML->load_xml(string => $xml);
    my $root = $dom->documentElement;
    my $xpc = XML::LibXML::XPathContext->new($root);
    my (@functions, @typedefs);

    my %typedef_for;
    for my $td_decl ($xpc->findnodes('//typedef_hash/typedef')) {
        my $typedef_name = $td_decl->getAttribute('id');
        my $xpath = '//externalDeclaration[descendant::IDENTIFIER[@text="'. $typedef_name .'"]]/@text';
        my $declaration = $xpc->findvalue($xpath);
        die ("Cannot find typedef for $typedef_name")
            unless defined $declaration;
        my $typedef = ClusterGLNG::TypeDef->new({
            name        => $typedef_name,
            declaration => $declaration,
        });
        push @typedefs, $typedef;
        $typedef_for{$typedef_name} = $typedef;
        print "Found typedef: $typedef_name\n";
    }
    my %has_use_of;

    my @function_declarations = $xpc->findnodes('//fdecls/fdecl');
    for my $f_decl (@function_declarations) {
        my $function_name = $f_decl->getAttribute('id');
        next unless $function_name =~ /$fname_filter/;
        my $decl_xpath = '//externalDeclaration[descendant::IDENTIFIER[@text="'. $function_name .'"]]';
        my ($declaraton_node) = $xpc->findnodes($decl_xpath);
        die "Cannot find function declaration for $function_name"
            unless defined $declaraton_node;
        my $return_type = $xpc->findvalue(
            'descendant::declarationCheckdeclarationSpecifiers/@text', $declaraton_node
        );
        die "Cannot find return type for $function_name"
            unless defined $return_type;

        my @params;
        for my $param_node ($xpc->findnodes('descendant::parameterDeclaration', $declaraton_node) ) {
            my $param_name = $xpc->findvalue('descendant::IDENTIFIER/@text', $param_node);
            die("Cannot find parameter name for $function_name")
                unless defined $param_name;
            my $typedef_id = $xpc->findvalue('descendant::TYPEDEF_NAME/@text', $param_node);
            my ($typedef, $type);
            if ($typedef_id) {
                die("Cannot find typedef name for $function_name")
                    unless defined $typedef_id;
                $typedef = $typedef_for{$typedef_id} // die("No typedef for $typedef_id ($function_name)");
                $has_use_of{$typedef_id} = 1;
            }
            else {
                # OK, some of build-in types
                $type = $xpc->findvalue('descendant::typeSpecifier1/@text', $param_node);
            }

            next if (!$typedef && $type && $type eq 'void');

            my ($const) = $xpc->findnodes(
                "//typeSpecifier1[\@text='$typedef_id']/../descendant::typeQualifier[\@text='const']",
                $param_node);

            my ($pointer) = $xpc->findnodes(
                "//directDeclarator[\@text='$param_name']/../pointer",
                $param_name,
            );

            my $parameter = ClusterGLNG::Parameter->new({
                name       => $param_name,
                typedef    => $typedef,
                is_pointer => defined($pointer),
                is_const   => defined($const),
            });
            push @params, $parameter;
        }
        print "Found function: $function_name\n";
        push @functions, ClusterGLNG::FunctionDef->new({
            id          => scalar(@functions),
            name        => $function_name,
            return_type => $return_type,
            parameters  => \@params,
        });
    }
    my @used_typedefs = grep { $has_use_of{$_->name} } @typedefs;

    return (\@functions, \@used_typedefs);
}

1;
