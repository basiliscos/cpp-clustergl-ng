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
    my %context = @_;
    my $functions = $context{functions} // die("No functions context");
    my $typedefs  = $context{typedefs } // die("No typedefs context");
    my $skip      = $context{skip     } // {};

    my %generator_for = (
        declaration => sub {
            my ($output) = @_;
            state $renderer = build_mt('<?= $_[0]->declaration ?>');
            for my $t (@$typedefs) {
                $output->print($renderer->($t), "\n");
            }
            $output->print("\n") if(@$typedefs);
            for my $f (@$functions) {
                $output->print(render_mt(<<'FUNDECL_END', $f, $skip)->as_string);
? my ($f, $skip) = @_;
? my $params = $f->parameters;
? my @declared_params = map { $_->type(1).' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
? my $orig_params = join(', ', @declared_params);
? my $packer_params = join(', ', 'Instruction *_instruction', @declared_params);
/* <?= $f->id ?> */
<?= $f->return_type ?> <?= $f->name ?>(<?= $orig_params ?>);
void packer_<?= $f->name ?>(<?= $packer_params ?>);
void exec_<?= $f->name ?>(Instruction *_i, void* executor);
? unless (exists $skip->{ 'NO_serializer_' . $f->name }) {
?   my @const_ptr_params = grep { $_->pointer && $_->is_const } @$params;
?   for my $p (@const_ptr_params) {
uint32_t <?= join('_', $f->name, $p->name, 'size') ?>(<?= $orig_params ?>); /* have to be provided manually */
?   }
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
? my @pointer_params = grep { $_->pointer && !$_->is_const } @$params;
? my $need_reply = $f->return_type ne 'void' || @pointer_params;


/* <?= $f->id ?>, has_packer: <?= $has_packer ?>, need reply: <?= $need_reply ?> */
extern "C" <?= $f->return_type ?> <?= $f->name ?>(<?= join(', ', @declared_params) ?>){
        Interceptor& my_interceptor = Interceptor::get_instance();
        Instruction *my_instruction = my_interceptor.create_instruction(<?= $f->id ?>, <?= $need_reply ? 'INSTRUCTION_NEED_REPLY' : 0 ?>);
? if ($has_packer) {
        <?= $packer_name ?>(<?= $packer_params ?>);
? }
? if ($need_reply) {
        my_interceptor.intercept_with_reply(my_instruction);
?   if ($f->return_type ne 'void' && !@pointer_params) {
?     if($f->return_type !~ /\*/) {
        <?= $f->return_type ?> * reply_ptr = (<?= $f->return_type ?> *)my_instruction->get_reply();
        return *reply_ptr;
?     } else {
        <?= $f->return_type ?> reply = (<?= $f->return_type ?>)my_instruction->get_reply();
        return reply;
?     }
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
        'packed/dumper' => sub {
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
? my @pointer_params = grep { $_->pointer && !$_->is_const } @$params;
? my @dumpable_params = grep { !$_->pointer && !$_->fixed_size } @$params;
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
        'packed/dumper/list' => sub {
            my ($output) = @_;
            $output->print(render_mt(<<'PD_LIST_END', $functions)->as_string);
? my ($functions) = @_;
void cglng_fill_packed_dumpers(void *location) {
    CGLNG_simple_function* ptr = (CGLNG_simple_function*)location;
? for my $f (@$functions) {
?   my @pointer_params = grep { $_->pointer && !$_->is_const } @{ $f->parameters };
?   my $need_reply = $f->return_type ne 'void' || @pointer_params;
    *ptr++ =<?= $need_reply? '(CGLNG_simple_function)(' : '' ?> &dump_<?= $f->name ?><?= $need_reply? ')' : '' ?>;
? }
}
PD_LIST_END
        },
        function_names => sub {
            my ($output) = @_;
            my $template = Text::MicroTemplate->new(template => <<'NAMES_LIST_END', escape_func => undef);
? my ($functions) = @_;
? my $names = join(",\n", map { '"'.$_->name.'"' } @$functions);
const char **cglng_function_names = (const char*[]) {
  <?= $names ?>
};

NAMES_LIST_END
                $output->print(eval($template->code)->($functions));
        },
        'packed/executor' => sub {
            my ($output) = @_;
            for my $f (@$functions) {
                my $template = Text::MicroTemplate->new(template => <<'PACKED_EXECUTOR_END', escape_func => undef);
? my ($f) = @_;
? my $params = $f->parameters;
? my @pointer_params = grep { $_->pointer && !$_->is_const } @$params;
? my @dumpable_params = grep { !$_->pointer && !$_->fixed_size } @$params;
? my $need_reply = $f->return_type ne 'void' || @pointer_params;
void exec_<?= $f->name ?>(<?= join(', ', 'Instruction *_i', 'void* executor') ?>){
?   if (@$params) {
        void* my_ptr = _i->get_packed();
?   }
?   for my $p (@$params) {
?       my $p_type = $p->type(0) . ($p->fixed_size? '*' : '') . '*';
?       my $ptr_name = '_' . $p->name . '_ptr';
        <?= $p_type ?> <?= $ptr_name ?> = (<?= $p_type ?>) my_ptr;
        <?= $p->type.($p->fixed_size? '*' : '') ?> <?= $p->name ?> = *<?= $ptr_name ?>++; my_ptr = <?= $ptr_name ?>;
?   }
?       my $param_types = join(', ', map { $_->type(0) . ($_->fixed_size? '*' : '') } @$params );
        <?= $f->return_type ?> (*my_<?= $f->name ?>)(<?= $param_types ?>) = (<?= $f->return_type ?> (*)(<?= $param_types ?>))executor;
?  my ($reply, $post_reply_action) = ('', '');
?  if($need_reply && $f->return_type ne 'void' && $f->return_type !~ /\*/) {
        static <?= $f->return_type ?> _reply;
        _i->store_reply((void*)&_reply, false);
?       $reply = '_reply = ';
?  } elsif($need_reply && $f->return_type =~ /\*/) {
?       $reply = $f->return_type . ' _reply = ';
?       $post_reply_action = '_i->store_reply((void*)_reply, false)';
?  } elsif($need_reply) {
       /* indirect reply via one of input paramterers */
?  }
        <?= $reply ?>(*my_<?= $f->name ?>)(<?= join(', ', map { $_->name } @$params ) ?>);
        <?= $post_reply_action ?>;
}
PACKED_EXECUTOR_END
                $output->print(eval($template->code)->($f));
            }
        },
        'packed/executor/list' => sub {
            my ($output) = @_;
            $output->print(render_mt(<<'PE_LIST_END', $functions)->as_string);
? my ($functions) = @_;
void cglng_fill_packed_executors(void *location) {
    CGLNG_executor_function* ptr = (CGLNG_executor_function*)location;
? for my $f (@$functions) {
    *ptr++ = &exec_<?= $f->name ?>;
? }
}
PE_LIST_END
        },
        serializer => sub {
            my ($output) = @_;
            for my $f (@$functions) {
                next if exists $skip->{'NO_serializer_' . $f->name};
                $output->print(render_mt(<<'SERIALIZER_END', $f)->as_string);
? my ($f) = @_;
? my $name = 'serializer_' . $f->name;
? my $params = $f->parameters;
? my @declared_params = map { $_->type(1).' '. $_->name.($_->fixed_size? '['.$_->fixed_size.']' : '') } @$params;
? my $orig_params = join(', ', map { $_->name } @$params);
? my @pointer_params = grep { $_->pointer && $_->is_const } @$params;
? my @pointer_return_params = grep { $_->pointer && !$_->is_const } @$params;
? my @fixed_params = grep { $_->fixed_size } @$params;
? my $need_reply = $f->return_type ne 'void' || @pointer_return_params;

/* <?= $f->id ?> */
void <?= $name ?>(<?= join(', ', 'Instruction *_instruction', 'int direction') ?>){
? if (@pointer_params || @pointer_return_params || @fixed_params) {
            char* my_ptr = (char*)_instruction->get_packed();
?    for my $p (@$params) {
?       my $p_type = $p->type(0) . ($p->fixed_size? '*' : '') . '*';
?       my $ptr_name = '_' . $p->name . '_ptr';
            <?= $p_type ?> <?= $ptr_name ?> = (<?= $p_type ?>) my_ptr;
            <?= $p->type.($p->fixed_size? '*' : '') ?> <?= $p->name ?> = *<?= $ptr_name ?>++; my_ptr = (char*) <?= $ptr_name ?>;
?    }
? }
? if (! @$params) {
        /* no arguments, no need to serialize */
? } elsif (!@pointer_params && !@fixed_params) {
     if (direction == DIRECTION_FORWARD ) {
          /* all arguments are simple, take copy from packed */
         const uint32_t size = _instruction->packed_size();
         /* overhead copy (should be ignored on deserialization) : <?= join(', ', map { $_->name } @pointer_return_params) ?> */
         memcpy(_instruction->serialize_allocate(size), _instruction->get_packed(), size);
     }
? } else {
     if (direction == DIRECTION_FORWARD ) {
?      my @ptr_sizes = grep { $_->pointer && $_->is_const } @$params;
?      for my $p (@ptr_sizes) {
            uint32_t size_for_<?= $p->name ?> = <?= $f->name ?>_<?= $p->name ?>_size(<?= $orig_params ?>);
?      }
?      my @sizes =  map { !(($_->pointer && $_->is_const) || $_->fixed_size)
?                         ? 'sizeof(' . $_->name . ')'
?                         : $_->fixed_size
?                         ? '( ' . $_->fixed_size . ' * sizeof(' . $_->type(0) . '))'
?                         : "(sizeof(uint32_t) + size_for_" . $_->name . ')';
?                   } @$params;
            uint32_t _total_size = <?= join("+", @sizes);  ?>;
            char* _serialized_ptr = (char*) _instruction->serialize_allocate(_total_size);
?      for my $p (@$params) {
?         my $p_type = $p->type(0) . ($p->fixed_size? '*' : '') . '*';
?         my $ptr_name = '_serialized_' . $p->name . '_ptr';
?         my $size_var = "size_for_".  $p->name;
?         if ( !($p->pointer && $p->is_const) && !$p->fixed_size ) {
            <?= $p_type ?> <?= $ptr_name ?> = (<?= $p_type ?>) _serialized_ptr;
            *<?= $ptr_name ?>++ = <?= $p->name ?>; _serialized_ptr = (char*) <?= $ptr_name ?>;
?         } elsif ( $p->fixed_size ) {
            uint32_t <?= $size_var ?> = ( <?= $p->fixed_size ?> * sizeof( <?= $p->type(0) ?> ));
            memcpy(_serialized_ptr, <?= $p->name ?>, <?= $size_var ?> );
            _serialized_ptr += <?= $size_var ?>;
?         } elsif ( $p->pointer && $p->is_const) {
            uint32_t* <?= $ptr_name ?> = (uint32_t*) _serialized_ptr;
            *<?= $ptr_name ?>++ = <?=  $size_var ?>; _serialized_ptr = (char*) <?= $ptr_name ?>;
            memcpy(_serialized_ptr, <?= $p->name ?>, <?= $size_var ?>); _serialized_ptr += <?= $size_var ?>;
?         }
?      }
     }
? }

? if (!$need_reply) {
            /* no reply, no serialized result deserialization */
? } elsif ($f->return_type !~ /\*/) {
     if (direction == DIRECTION_BACKWARD ) {
?       if ($f->return_type ne 'void') {
            /* reply is simple, copy serialized */
          _instruction->store_reply(_instruction->get_serialized_reply(), false);
?       } else {
            char* reply_ptr = (char*) _instruction->get_serialized_reply();
?         for my $p (@pointer_return_params) {
?           my $size_var = "size_for_".  $p->name;
            uint32_t* <?= $size_var ?>_ptr = (uint32_t*) reply_ptr;
            uint32_t <?= $size_var ?> = *<?= $size_var ?>_ptr++; reply_ptr = (char*) <?= $size_var ?>_ptr;
            memcpy(<?= $p->name ?>, reply_ptr, <?= $size_var ?>);
?         }
?       }
     }
? }
}
SERIALIZER_END
            }
        }
    );

    return sub {
        my ($role) = @_;
        my $generator = $generator_for{$role} // croak("No $role generator");
        return $generator;
    };
};

1;
