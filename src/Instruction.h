#ifndef _INSTRUCTION_H
#define _INSTRUCTION_H

#include "common.h"

class Instruction {
 private:
  
  void* serialized_args;
  uint32_t args_size;
  void* reply;
  bool reply_owner;
  
 public:
  const uint32_t id;
  Instruction(uint32_t instruction_id);
  ~Instruction();
  
  void* preallocate(uint32_t size);
  void store_reply(void* reply, bool reply_owner);
  void* get_reply();
};

#endif /* _INSTRUCTION_H */
