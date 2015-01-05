#include "Interceptor.h"
#include "common.h"
#include <dlfcn.h>

Interceptor& Interceptor::get_instance() {
  static Interceptor instance;
  return instance;;
}

Interceptor::Interceptor(){
  original_SDL_Init = NULL;
};

int Interceptor::intercept_sdl_init(unsigned int flags) {
  LOG("intercepted SDL_init\n");
  if (!original_SDL_Init){
    original_SDL_Init = (int (*)(unsigned int)) dlsym(RTLD_NEXT, "SDL_Init");
    if (!original_SDL_Init) {
      LOG("Cannot find SDL_Init: %s\n", dlerror());
      exit(1);
    }

    int result = (*original_SDL_Init)(flags);

    return result;
  }
}

Instruction* Interceptor::create_instruction(uint32_t id){
  Instruction* i = new Instruction(id);
  queue.push_back(i);
  return i;
}

extern "C" int SDL_Init(unsigned int flags) {
  return Interceptor::get_instance().intercept_sdl_init(flags);
};

