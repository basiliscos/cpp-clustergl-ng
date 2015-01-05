#include "Interceptor.h"
#include "common.h"

static Interceptor instance;

Interceptor::Interceptor(){
  original_SDL_Init = NULL;
};

void Interceptor::intercept_sdl_init(unsigned int flags) {
  LOG("intercepted SDL_init\n");
}


extern "C" int SDL_Init(unsigned int flags) {
  instance.intercept_sdl_init(flags);
};

