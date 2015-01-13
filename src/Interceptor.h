#ifndef _INTERCEPTOR_H
#define _INTERCEPTOR_H

#include "Instruction.h"
#include "Processor.h"

class Interceptor
{
 private:
  int (*original_SDL_Init)(unsigned int flags);
  Interceptor();
 public:
  static Interceptor& get_instance();
  int intercept_sdl_init(unsigned int flags);
  Instruction* create_instruction(uint32_t id);
  void intercept(Instruction *i);
  void intercept_with_reply(Instruction *i);
};

#endif /* _INTERCEPTOR_H */

