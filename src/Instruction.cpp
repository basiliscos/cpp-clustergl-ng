#include "Instruction.h"


Instruction::Instruction(uint32_t instruction_id, unsigned char my_flags):
  id(instruction_id), flags(my_flags) {
  _ref_count = 1;
  _packed_args = NULL;
  _pack_size = 0;
  _packed_owner = false;
  _reply = NULL;
  _reply_owner = false;
  _serialized = NULL;
  _serialized_size = 0;
  _serialized_reply = NULL;
  _serialized_reply_size = 0;
}

Instruction::~Instruction(){
  if(_packed_args && (_pack_size || _packed_owner)) {
    free(_packed_args);
  }
  if(_reply && _reply_owner){
    free(_reply);
  }
  if(_serialized_size && _serialized) {
    free(_serialized);
  }
  if(_serialized_reply_size && _serialized_reply){
    free(_serialized_reply);
  }
  if(_ref_count > 0) {
    LOG("Warning, relasing non-released Instruction %d... going do die\n", id);
    abort();
  }else if(_ref_count < 0){
    LOG("Warning, relasing over-released (ref_count < 0) Instruction %d... going do die\n", id);
    abort();
  }
}


int Instruction::references_count() {
  return _ref_count;
}

void Instruction::acquire() {
  _ref_count++;
}

void Instruction::release() {
  _ref_count--;
  if(_ref_count < 0) {
    LOG("Warning, negative count of references for instruction %d?\n", id);
  }
}

void* Instruction::pack_allocate(uint32_t size){
  _packed_args = malloc(size);
  _pack_size = size;
  _packed_owner = true;
  return _packed_args;
}

void Instruction::store_packed(void * ptr, bool packed_owner) {
  _packed_args = ptr;
  _packed_owner = packed_owner;
}

void* Instruction::get_packed() {
  return _packed_args;
}

void Instruction::store_reply(void* reply, bool reply_owner){
  _reply = reply;
  _reply_owner = reply_owner;
}

void* Instruction::get_reply() {
  if (!_reply) {
    LOG("Oops! Trying to get reply for instruction %d, without set it previously... going do die\n", id);
    abort();
  }
  return _reply;
}

void* Instruction::serialize_allocate(uint32_t size) {
  _serialized = malloc(size);
  _serialized_size = size;
  return _serialized;

}

void* Instruction::get_serialized() {
  if (!_serialized) {
    LOG("Oops! Trying to get serialized for instruction %d, without set it previously... going do die\n", id);
    abort();
  }
  return _serialized;
}

uint32_t Instruction::serialized_size() {
  return _serialized_size;
}

void* Instruction::serialized_reply_allocate(uint32_t size) {
  _serialized_reply = malloc(size);
  _serialized_reply_size = size;
  return _serialized_reply;
}

void* Instruction::get_serialized_reply() {
  if (!_serialized_reply) {
    LOG("Oops! Trying to get serialized reply for instruction %d, without set it previously... going do die\n", id);
    abort();
  }
  return _serialized_reply;
}

uint32_t Instruction::serialized_reply_size() {
  return _serialized_reply_size;
}
