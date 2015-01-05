#ifndef _INTERCEPTOR_H
#define _INTERCEPTOR_H

#include "Instruction.h"

class Interceptor
{
 private:
  int (*original_SDL_Init)(unsigned int flags);
  Interceptor();
  vector<Instruction*> queue;
 public:
  static Interceptor& get_instance();
  int intercept_sdl_init(unsigned int flags);
  Instruction* create_instruction(uint32_t id);
};

#endif /* _INTERCEPTOR_H */

