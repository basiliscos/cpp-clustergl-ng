#include "custom_commands.h"

void exec_cglng_SDL_GetVideoInfo(Instruction *_i, void* executor){
  SDL_VideoInfo* (*my_SDL_GetVideoInfo)(void) = (SDL_VideoInfo* (*)(void))executor;
  SDL_VideoInfo* _reply = (*my_SDL_GetVideoInfo)();
  _i->store_reply((void*)_reply, false);
}
