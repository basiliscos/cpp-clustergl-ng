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
        declaration => sub {
            my ($output) = @_;
            state $renderer = build_mt('<?= $_[0]->declaration ?>');
            for my $t (@$typedefs) {
                $output->print($renderer->($t), "\n");
            }
            $output->print("\n") if(@$typedefs);
            for my $f (@$functions) {
                $output->print(render_mt(<<'FUNDECL_END', $f)->as_string);
? my ($f) = @_;
? my $params = $f->parameters;
? my @declared_params = map { $_->type.' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
? my $orig_params = join(', ', @declared_params);
? my $packer_params = join(', ', 'Instruction *_instruction', @declared_params);
/* <?= $f->id ?> */
<?= $f->return_type ?> <?= $f->name ?>(<?= $orig_params ?>);
void packer_<?= $f->name ?>(<?= $packer_params ?>);
? my @const_ptr_params = grep { $_->is_pointer && $_->is_const } @$params;
? for my $p (@const_ptr_params) {
uint32_t <?= join('_', $f->name, $p->name, 'size') ?>(<?= $orig_params ?>); /* have to be provided manually */
? }
FUNDECL_END
            }
            $output->print("\n") if(@$functions);
        },
        capturer => sub {
            my ($output) = @_;
            for my $f (@$functions) {
                $output->print(render_mt(<<'CAPTURE_END', $f)->as_string);
? my ($f) = @_;
? my $params = $f->parameters;
? my $has_packer = scalar(@$params);
? my @declared_params = map { $_->type.' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
? my $packer_params = $has_packer &&
?       join(', ', 'my_instruction', map { $_->name } @$params);
? my $packer_name = "packer_" . $f->name;
? my @pointer_params = grep { $_->is_pointer && !$_->is_const } @$params;
? my $need_reply = $f->return_type ne 'void' || @pointer_params;


/* <?= $f->id ?>, has_packer: <?= $has_packer ?>, need reply: <?= $need_reply ?> */
<?= $f->return_type ?> <?= $f->name ?>(<?= join(', ', @declared_params) ?>){
      Interceptor& my_interceptor = Interceptor::get_instance();
      Instruction *my_instruction = my_interceptor.create_instruction(<?= $f->id ?>);
? if ($has_packer) {
      <?= $packer_name ?>(<?= $packer_params ?>);
? }
? if ($need_reply) {
      my_interceptor.intercept_with_reply(my_instruction);
      <?= $f->return_type ?> * reply = (<?= $f->return_type ?> *)my_instruction->get_reply();
?   if ($f->return_type ne 'void' && !@pointer_params) {
      return *reply;
?   } else {
?     my $pointer_names = join(', ', map { $_->name } @pointer_params);
      LOG("<?= $f->name ?> is unimplemeted: for <?= $pointer_names ?>\n");
      abort();
?   }
? } else {
      my_interceptor.intercept(my_instruction);
? }
}

CAPTURE_END
            }
        },
        packer => sub {
            my ($output) = @_;
            for my $f (@$functions) {
                my $function_name = "packer_" . $f->name;
                my $params = $f->parameters;
                $output->print(render_mt(<<'SIGNATURE_END', $f, $function_name)->as_string);
? my ($f, $name) = @_;
? my $params = $f->parameters;
? my @declared_params = map { $_->type.' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
? my $orig_params = join(', ', map { $_->name } @$params)

/* <?= $f->id ?> */
void <?= $name ?>(<?= join(', ', 'Instruction *_instruction', @declared_params) ?>){
? if (! @$params) {
        LOG("NO packer for <?= $name ?>\n");
        abort();
? } else {
?   my @const_ptr_params = grep { $_->is_pointer && $_->is_const } @$params;
?   for my $p (@const_ptr_params) {
        const uint32_t _size_of_<?= $p->name ?> = <?= join('_', $f->name, $p->name, 'size') . '( ' . $orig_params . ')' ?>;
?   }
?   my %is_const_ptr = map { $_->name => 1 } @const_ptr_params;
?   my @fixed_size_params = grep { $_->fixed_size } @$params;
?   for my $p (@fixed_size_params) {
        const uint32_t _size_of_<?= $p->name ?> = sizeof(<?= $p->type ?>) * <?= $p->fixed_size ?>;
?   }
?   my %is_fixed_size = map { $_->name => 1 } @fixed_size_params;
?   my @sizes = map { ($_->is_pointer && $_->is_const) || $_->fixed_size
?      ? '_size_of_' . $_->name
?      : 'sizeof(' . $_->type . ')'
?   } @$params;
        const uint32_t _size = <?= join('+', @sizes ); ?>;
        void* _ptr = _instruction->preallocate(_size);
?   for my $p (@$params) {
?     my $ptr_name = '_' . $p->name . '_ptr';
?     if ($is_const_ptr{$p->name} || $is_fixed_size{$p->name}) {
?       my $p_size = '_size_of_' . $p->name;
        memcpy(_ptr, <?= $p->name ?>, <?= $p_size ?>); char* <?= $ptr_name ?> = (char*)(_ptr); <?= $ptr_name ?> += <?= $p_size ?>; _ptr = (void*)(<?= $ptr_name ?>);
?     } else {
?       my $p_type = $p->type . '*';
        <?= $p_type ?> <?= $ptr_name ?> = (<?= $p_type ?>) _ptr; *<?= $ptr_name ?>++ = <?= $p->name ?>; _ptr = (void*)(<?= $ptr_name ?>);
?     }
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
