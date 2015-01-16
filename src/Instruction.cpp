#include "Instruction.h"


Instruction::Instruction(uint32_t instruction_id):id(instruction_id){
  packed_args = NULL;
  pack_size = 0;
  reply = NULL;
  reply_owner = false;
  ref_count = 1;
}

Instruction::~Instruction(){
  if(packed_args && pack_size) {
    free(packed_args);
  }
  if(reply && reply_owner){
    free(reply);
  }
  if(ref_count > 0) {
    LOG("Warning, relasing non-released Instruction... going do die\n");
    abort();
  }else if(ref_count < 0){
    LOG("Warning, relasing over-released (ref_count < 0) Instruction... going do die\n");
    abort();
  }
}

void* Instruction::pack_allocate(uint32_t size){
  packed_args = malloc(size);
  pack_size = size;
  return packed_args;
}

void* Instruction::get_packed() {
  return packed_args;
}

void Instruction::store_reply(void* reply, bool reply_owner){
  this->reply = reply;
  this->reply_owner = reply_owner;
}

void* Instruction::get_reply() {
  if (!reply) {
    LOG("Oops! Trying to get reply for instruction %d, without set it previously... going do die\n", id);
    abort();
  }
  return reply;
}

int Instruction::references_count() {
  return ref_count;
}

void Instruction::acquire() {
  ref_count++;
}

void Instruction::release() {
  ref_count--;
  LOG("Warning, negative count of references?\n");
}
