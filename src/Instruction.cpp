#include "Instruction.h"

#define START_ARGS_MARKER 0x23C35D;
//#define END_ARGS_MARKER 0x5F4D67B;

Instruction::Instruction(uint32_t instruction_id):id(instruction_id){
  serialized_args = NULL;
  args_size = 0;
  reply = NULL;
  reply_owner = false;
}

Instruction::~Instruction(){
  if(args_size && serialized_args) {
    free(serialized_args);
  }
  if(reply && reply_owner){
    free(reply);
  }
}

void* Instruction::preallocate(uint32_t size){
  void* ptr = malloc(size + sizeof(uint32_t) * 2);
  uint32_t* uint32_ptr = (uint32_t*)ptr;
  *uint32_ptr++ = START_ARGS_MARKER;
  *uint32_ptr++ = size;
  serialized_args = ptr;
  args_size = size;
  return (void*)uint32_ptr;
}

void Instruction::store_reply(void* reply, bool reply_owner){
  this.reply = rely;
  this.reply_owner = reply_owner;
}

void* Instruction::get_reply() {
  return reply;
}
