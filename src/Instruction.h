#ifndef _INSTRUCTION_H
#define _INSTRUCTION_H

#include "common.h"

#define INSTRUCTION_NEED_REPLY 1
#define INSTRUCTION_CUSTOM 2

class Instruction {
 private:

  int _ref_count;
  void* _packed_args;
  uint32_t _pack_size;
  void* _reply;
  bool _reply_owner;
  void* _serialized;
  uint32_t _serialized_size;
  void* _serialized_reply;
  uint32_t _serialized_reply_size;

 public:
  const uint32_t id;
  const unsigned char flags;
  Instruction(uint32_t instruction_id, unsigned char my_flags = 0);
  ~Instruction();

  void* pack_allocate(uint32_t size);
  void* get_packed();

  void store_reply(void* reply, bool reply_owner);
  void* get_reply();

  void* serialize_allocate(uint32_t size);
  void* get_serialized();
  uint32_t serialized_size();

  void* serialized_reply_allocate(uint32_t size);
  void* get_serialized_reply();
  uint32_t serialized_reply_size();

  int references_count();
  void acquire();
  void release();
};

typedef void(*CGLNG_simple_function)(Instruction* i);
typedef void(*CGLNG_directed_function)(Instruction* i, int direction);

typedef void(*CGLNG_executor_function)(Instruction* i, void* executor);


#endif /* _INSTRUCTION_H */
