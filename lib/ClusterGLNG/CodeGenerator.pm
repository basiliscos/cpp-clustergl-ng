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
? my @declared_params = map { $_->type(1).' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
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
? my @declared_params = map { $_->type(1).' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
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
                $output->print(render_mt(<<'SIGNATURE_END', $f, $function_name)->as_string);
? my ($f, $name) = @_;
? my $params = $f->parameters;
? my @declared_params = map { $_->type(1).' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
? my $orig_params = join(', ', map { $_->name } @$params)

/* <?= $f->id ?> */
void <?= $name ?>(<?= join(', ', 'Instruction *_instruction', @declared_params) ?>){
? if (! @$params) {
        LOG("NO packer for <?= $name ?>\n");
        abort();
? } else {
?   my @sizes = map { 'sizeof(' . $_->type(0).($_->fixed_size? '*' : '').'*)' } @$params;
        const uint32_t _size = <?= join('+', @sizes ); ?>;
        void* _ptr = _instruction->pack_allocate(_size);
?   for my $p (@$params) {
?       my $p_type = $p->type(1) . ($p->fixed_size? '*' : '') . '*';
?       my $ptr_name = '_' . $p->name . '_ptr';
        <?= $p_type ?> <?= $ptr_name ?> = (<?= $p_type ?>) _ptr; *<?= $ptr_name ?>++ = <?= $p->name ?>; _ptr = (void*)(<?= $ptr_name ?>);
?   }
? }
}
SIGNATURE_END
            }
        },
        packed_dumper => sub {
            my %print_hint_for = (
                GLenum     => 'u',
                GLboolean  => 'uc',
                GLbitfield => 'u',
                GLbyte     => 'c',
                GLshort    => 'd',
                GLint      => 'd',
                GLubyte    => 'uc',
                GLushort   => 'uh',
                GLuint     => 'ud',
                GLsizei    => 'd',
                GLfloat    => 'f',
                GLclampf   => 'f',
                GLdouble   => 'f',
                GLclampd   => 'f',
            );
            my ($output) = @_;
            for my $f (@$functions) {
                my $template = Text::MicroTemplate->new(template => <<'PACKED_DUMPER_END', escape_func => undef);
? my ($f, $print_hint_for) = @_;
? my $params = $f->parameters;
? my @pointer_params = grep { $_->is_pointer && !$_->is_const } @$params;
? my @dumpable_params = grep { !$_->is_pointer && !$_->fixed_size } @$params;
? my $need_reply = $f->return_type ne 'void' || @pointer_params;
void dump_<?= $f->name ?>(<?= join(', ', 'Instruction *_i', ($need_reply? ('int direction'): ()) ) ?>){
        const char* prefix = <?= $need_reply ? 'direction == DIRECTION_FORWARD ? "[>>]" : "[<<]"' : '""' ?>;
?   my $pattern = join(', ', map { $_->name.' = %'.$print_hint_for->{$_->type} } @dumpable_params);
?   if (@$params) {
        void* my_ptr = _i->get_packed();
?   }
?   for my $p (@$params) {
?       my $p_type = $p->type(0) . ($p->fixed_size? '*' : '') . '*';
?       my $ptr_name = '_' . $p->name . '_ptr';
        <?= $p_type ?> <?= $ptr_name ?> = (<?= $p_type ?>) my_ptr;
        <?= $p->type.($p->fixed_size? '*' : '') ?> <?= $p->name ?> = *<?= $ptr_name ?>++; my_ptr = <?= $ptr_name ?>;
?   }
        LOG("%s <?= $f->name ?>(<?= $pattern ?>)\n", <?= join(', ', qw/prefix/, map { $_->name } @dumpable_params ) ?> );
}

PACKED_DUMPER_END
                $output->print(eval($template->code)->($f, \%print_hint_for));
            }
        },
        packed_dumper_list => sub {
            my ($output) = @_;
            $output->print(render_mt(<<'PD_LIST_END', $functions)->as_string);
? my ($functions) = @_;
void cglng_fill_packet_dumpers(void *location) {
    CGLNG_simple_function* ptr = (CGLNG_simple_function*)location;
? for my $f (@$functions) {
?   my @pointer_params = grep { $_->is_pointer && !$_->is_const } @{ $f->parameters };
?   my $need_reply = $f->return_type ne 'void' || @pointer_params;
    *ptr++ =<?= $need_reply? '(CGLNG_simple_function)(' : '' ?> &dump_<?= $f->name ?><?= $need_reply? ')' : '' ?>;
? }
}
PD_LIST_END
        },
    );

    return sub {
        my ($role) = @_;
        my $generator = $generator_for{$role} // croak("No $role generator");
        return $generator;
    };
};

1;
