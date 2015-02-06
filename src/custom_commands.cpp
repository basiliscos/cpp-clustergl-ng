#include "custom_commands.h"
#include <dlfcn.h>

const char **cglng_custom_function_names = (const char*[]) {
  "SDL_GetVideoInfo",
};

void dump_cglng_SDL_GetVideoInfo(Instruction* i, int direction) {
  const char* prefix = direction == DIRECTION_FORWARD ? "[>>]" : "[<<]";
  LOG("%s SDL_GetVideoInfo()\n", prefix );
}

void exec_cglng_SDL_GetVideoInfo(Instruction *_i, void* executor){
  LOG("exec_cglng_SDL_GetVideoInfo()\n");

  if ( SDL_Init( SDL_INIT_VIDEO ) < 0 ) {
    LOG( "Video initialization failed: %s\n", SDL_GetError());
    abort();
  }

  executor = dlsym(RTLD_NEXT, "SDL_GetVideoInfo");
  if(!executor) {
    LOG("Warning: cannot find local symbol: SDL_GetVideoInfo, aborting...\n");
    abort();
  }

  SDL_VideoInfo* (*my_SDL_GetVideoInfo)(void) = (SDL_VideoInfo* (*)(void)) executor;
  SDL_VideoInfo* _reply = (*my_SDL_GetVideoInfo)();
  _i->store_reply((void*)_reply, false);
}

void serializer_cglng_SDL_GetVideoInfo(Instruction *i, int direction) {
  if (direction = DIRECTION_FORWARD ) {
    const uint32_t size = sizeof(uint32_t) * 2 + 1;
    uint32_t *ptr = (uint32_t*) i->serialize_allocate(size);
    *ptr++ = i->id;
    unsigned char *flags_ptr = (unsigned char*) ptr;
    *flags_ptr++ = INSTRUCTION_NEED_REPLY;
    ptr = (uint32_t*)flags_ptr;
    *ptr++ = 0; /* no serialized arguments */
  } else {
    i->store_reply(i->get_serialized_reply(), false);
  }
}

void deserializer_cglng_SDL_GetVideoInfo(Instruction* i, int direction) {
  LOG("deserializer_cglng_SDL_GetVideoInfo() \n");
  // no arguments, nothing to de-serialize
  if (direction == DIRECTION_BACKWARD ) {
    uint32_t* ptr = (uint32_t*) i->serialized_reply_allocate(sizeof(uint32_t) + sizeof(SDL_VideoInfo));
    *ptr++ = sizeof(SDL_VideoInfo);
    memcpy(ptr, i->get_reply(), sizeof(SDL_VideoInfo));
  }
}

void cglng_custom_fill_packed_dumpers(void *location) {
  CGLNG_simple_function* ptr = (CGLNG_simple_function*)location;
  *ptr++ = (CGLNG_simple_function) &dump_cglng_SDL_GetVideoInfo;
}

void cglng_custom_fill_packed_executors(void *location) {
  CGLNG_executor_function* ptr = (CGLNG_executor_function*)location;
  *ptr++ = &exec_cglng_SDL_GetVideoInfo;
}

void cglng_custom_fill_deserializers(void *location) {
  CGLNG_simple_function* ptr = (CGLNG_simple_function*)location;
  *ptr++ = (CGLNG_simple_function) &deserializer_cglng_SDL_GetVideoInfo;
}
