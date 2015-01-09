package ClusterGLNG::CodeGenerator;
#Abstract: generates opengl-related code from function definitions

use 5.20.1;
use strict;
use warnings;

use Carp;
use Text::MicroTemplate qw(:all);

use parent qw/Exporter/;
our @EXPORT_OK = qw/create_generator/;

sub create_generator {
    my ($functions, $typedefs) = @_;

    my %generator_for = (
        typedefs => sub {
            my ($output) = @_;
            state $renderer = build_mt('<?= $_[0]->declaration ?>');
            for my $t (@$typedefs) {
                $output->print($renderer->($t), "\n");
            }
            $output->print("\n");
        },
        packer => sub {
            my ($output) = @_;
            for my $f (@$functions) {
                my $function_name = "packer_" . $f->name;
                my $params = $f->parameters;
                my $signature = join(', ', 'void *ptr', map {
                    $_->type .' ' .$_->name
                } @$params);
                $output->print(render_mt(<<'SIGNATURE_END', $f, $function_name, $signature)->as_string);
? my ($f, $name, $signature,) = @_;

/* <?= $f->id ?> */
<?= $f->return_type ?> <?= $name ?>(<?= $signature ?>){
? my $params = $f->parameters;
? if (! @$params) {
  LOG("NO packer for <?= $name ?>\n");
  abort();
? } else {
?   for my $p (@$params) {
?     my ($p_name, $p_type) = ('_' . $p->name . '_ptr', $p->type . '*');
      <?= $p_type ?> <?= $p_name ?> = (<?= $p_type ?>) ptr; *<?= $p_name ?>++ = <?= $p->name ?>; ptr = (void*)(<?= $p_name ?>);
?   }
? }
}
SIGNATURE_END
            }
        },
    );

    return sub {
        my ($role) = @_;
        my $generator = $generator_for{$role} // croak("No $role generator");
        return $generator;
    };
};

1;
