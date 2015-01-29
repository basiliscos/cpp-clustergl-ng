#include "Processor.h"

#include "custom_commands.h"
#include "Exception.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <netinet/in.h>
#include "SDL.h"

NetOutputProcessor::NetOutputProcessor(cfg_t *global_config, cfg_t *my_config, int socket) {
  _output = socket;

  /* step 1: get (sdl) video info from remote side */
  Instruction* i = new Instruction(CGLNG_SDL_GETVIDEOINFO_ID);
  dump_cglng_SDL_GetVideoInfo(i, DIRECTION_FORWARD);
  serializer_cglng_SDL_GetVideoInfo(i, DIRECTION_FORWARD);
  _send_instruction(i);
  _receive_reply(i);
  serializer_cglng_SDL_GetVideoInfo(i, DIRECTION_BACKWARD);
  dump_cglng_SDL_GetVideoInfo(i, DIRECTION_BACKWARD);
  SDL_VideoInfo* info = (SDL_VideoInfo*) i->get_reply();

  /* step 2: analyze remote video info and prepare make window command */
  int video_flags = SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE;
  if (info->hw_available) {
    video_flags |= SDL_HWSURFACE;
  } else {
    video_flags |= SDL_SWSURFACE;
  }

  if (info->blit_hw) {
    video_flags |= SDL_HWACCEL;
  }

  /* step 3: instruct remote side for creating window, wait for reply */
};

NetOutputProcessor::~NetOutputProcessor(){

}

void NetOutputProcessor::_send_instruction(Instruction* i) {
  uint32_t to_write = i->serialized_size();
  char *ptr = (char*) i->get_serialized();
  do {
    ssize_t written = write(_output, ptr, to_write);
    if ( written == -1 ) {
      perror("Error writing socket:");
      throw Exception("socket write error");
    }
    to_write -= written;
    ptr += written;
  } while ( to_write );
}

void NetOutputProcessor::_receive_reply(Instruction* i) {
  char buff[sizeof(uint32_t)]; /* only for size of serialized reply */
  char *buff_ptr = buff;
  ssize_t to_read = sizeof(uint32_t);
  do {
    ssize_t got = read(_output, buff_ptr, to_read);
    if (got < 0 ) {
      perror("Error reading socket:");
      throw Exception("socket write error");
    }
    to_read -= got;
    buff_ptr += got;
  } while (to_read);

  uint32_t *size_ptr = (uint32_t*) buff;
  uint32_t size = *size_ptr;
  buff_ptr = (char*) i->serialized_reply_allocate(size);
  to_read = (ssize_t) size;
  do {
    ssize_t got = read(_output, buff_ptr, to_read);
    if (got < 0 ) {
      perror("Error reading socket:");
      throw Exception("socket write error");
    }
    to_read -= got;
    buff_ptr += got;
  } while (to_read);
}

bool NetOutputProcessor::submit(vector<Instruction* > &queue) {
  abort();
}

bool NetOutputProcessor::query(Instruction* i, int direction) {
  abort();
}

bool NetOutputProcessor::is_terminal() { return true; }
