#include "custom_commands.h"
#include <dlfcn.h>

const char **cglng_custom_function_names = (const char*[]) {
  "SDL_GetVideoInfo",
};

Instruction* packed_cglng_MakeWindow(int32_t x, int32_t y, int32_t width, int32_t height) {
  Instruction* i = new Instruction(CGLNG_MAKE_WINDOW_ID, INSTRUCTION_CUSTOM | INSTRUCTION_NEED_REPLY);
  const uint32_t size = sizeof(int32_t)*4;
  int32_t *ptr = (int32_t*) i->pack_allocate(size);
  *ptr++ = x;
  *ptr++ = y;
  *ptr++ = width;
  *ptr++ = height;
  return i;
}

void dump_cglng_MakeWindow(Instruction* i, int direction) {
  const char* prefix = direction == DIRECTION_FORWARD ? "[>>]" : "[<<]";
  int32_t* ptr = (int32_t*) i->get_packed();
  int32_t x = *ptr++;
  int32_t y = *ptr++;
  int32_t width = *ptr++;
  int32_t height = *ptr++;
  LOG("%s MakeWindow(x = %d, y = %d, width = %d, height = %d)\n", prefix, x, y, width, height );
}

void exec_cglng_MakeWindow(Instruction *_i, void* executor){
  LOG("exec_cglng_MakeWindow()\n");

  if ( SDL_Init( SDL_INIT_VIDEO ) < 0 ) {
    LOG( "Video initialization failed: %s\n", SDL_GetError());
    abort();
  }

  executor = dlsym(RTLD_NEXT, "SDL_GetVideoInfo");
  if(!executor) {
    LOG("Warning: cannot find local symbol: SDL_GetVideoInfo, aborting...\n");
    abort();
  }

  SDL_VideoInfo* (*my_MakeWindow)(void) = (SDL_VideoInfo* (*)(void)) executor;
  SDL_VideoInfo* info = (*my_MakeWindow)();

  int video_flags;
  video_flags  = SDL_OPENGL;
  video_flags |= SDL_GL_DOUBLEBUFFER;
  video_flags |= SDL_HWPALETTE;

  if(info->hw_available ){
    video_flags |= SDL_HWSURFACE;
  }else{
    video_flags |= SDL_SWSURFACE;
  }

  if(info->blit_hw ){
    video_flags |= SDL_HWACCEL;
  }
  SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
  int32_t* ptr = (int32_t*) _i->get_packed();
  int32_t x = *ptr++;
  int32_t y = *ptr++;
  int32_t width = *ptr++;
  int32_t height = *ptr++;

  //set window position
  std::stringstream stream;
  stream << x << "," << y;
  setenv("SDL_VIDEO_WINDOW_POS", stream.str().c_str(), true);

  //get a SDL surface
  SDL_Surface *surface = SDL_SetVideoMode(width, height, 32, video_flags );

  unsigned char result = 0;
  if ( !surface ) {
    LOG( "Video mode set failed: %s\n", SDL_GetError());
  } else {
    result = 1;
  }

  //Disable mouse pointer
  //SDL_ShowCursor(SDL_DISABLE);

  //Do this twice - above works for OSX, here for Linux
  //Yeah, I know.
  //SDL_WM_SetCaption(title.c_str(), title.c_str());

  unsigned char *reply = (unsigned char*) malloc(1);
  *reply = result;
  LOG("MakeWindow result: %d\n", (int)result);
  _i->store_reply( reply, true);
}

void serializer_cglng_MakeWindow(Instruction *i, int direction) {
  if (direction == DIRECTION_FORWARD ) {
    const uint32_t size = sizeof(uint32_t) * 2 + 1 + sizeof(int32_t)*4;
    uint32_t *ptr = (uint32_t*) i->serialize_allocate(size);
    *ptr++ = i->id;
    unsigned char *flags_ptr = (unsigned char*) ptr;
    *flags_ptr++ = INSTRUCTION_NEED_REPLY;
    ptr = (uint32_t*)flags_ptr;
    *ptr++ = sizeof(int32_t)*4;
    memcpy(ptr, i->get_packed(), sizeof(int32_t)*4);
  } else {
    i->store_reply(i->get_serialized_reply(), false);
  }
}

void deserializer_cglng_MakeWindow(Instruction* i, int direction) {
  LOG("deserializer_cglng_MakeWindow() \n");
  if (direction == DIRECTION_FORWARD ) {
    i->store_packed(i->get_serialized(), false);
  } else {
    uint32_t* ptr = (uint32_t*) i->serialized_reply_allocate(sizeof(uint32_t) + sizeof(SDL_VideoInfo));
    *ptr++ = sizeof(SDL_VideoInfo);
    memcpy(ptr, i->get_reply(), sizeof(SDL_VideoInfo));
  }
}

void cglng_custom_fill_packed_dumpers(void *location) {
  CGLNG_simple_function* ptr = (CGLNG_simple_function*)location;
  *ptr++ = (CGLNG_simple_function) &dump_cglng_MakeWindow;
}

void cglng_custom_fill_packed_executors(void *location) {
  CGLNG_executor_function* ptr = (CGLNG_executor_function*)location;
  *ptr++ = &exec_cglng_MakeWindow;
}

void cglng_custom_fill_deserializers(void *location) {
  CGLNG_simple_function* ptr = (CGLNG_simple_function*)location;
  *ptr++ = (CGLNG_simple_function) &deserializer_cglng_MakeWindow;
}
