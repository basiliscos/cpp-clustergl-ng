#include "Processor.h"

#include "custom_commands.h"
#include "Exception.h"

#include "SDL.h"

NetOutputProcessor::NetOutputProcessor(cfg_t *global_config, cfg_t *my_config, int socket) {
  _output = socket;

  int32_t x = cfg_getint(my_config, "position_x");
  int32_t y = cfg_getint(my_config, "position_y");
  int32_t width = cfg_getint(my_config, "size_x");
  int32_t height = cfg_getint(my_config, "size_y");
  Instruction* i = packed_cglng_MakeWindow(x, y, width, height);
  dump_cglng_MakeWindow(i, DIRECTION_FORWARD);
  serializer_cglng_MakeWindow(i, DIRECTION_FORWARD);
  _send_instruction(i);
  LOG("MakeWindow sent\n");
  _receive_reply(i);
  serializer_cglng_MakeWindow(i, DIRECTION_BACKWARD);
  dump_cglng_MakeWindow(i, DIRECTION_BACKWARD);
  unsigned char result = *((unsigned char*) i->get_reply());
  LOG("Remote side intitialization result: %d\n", (int)result);

  i->release();
  delete i;
}

NetOutputProcessor::~NetOutputProcessor(){

}

void NetOutputProcessor::_send_instruction(Instruction* i) {
  char buff[sizeof(uint32_t)*2+1];
  uint32_t* buff_ptr = (uint32_t*) buff;
  uint32_t serialized_size = i->serialized_size();
  *buff_ptr++ = i->id;
  *buff_ptr++ = serialized_size;
  *((unsigned char*)buff_ptr) = i->flags;
  uint32_t to_write = sizeof(uint32_t)*2+1;
  char* ptr = buff;

  /* write signature: instuction id, size of args, flags */
  do {
    ssize_t written = write(_output, ptr, to_write);
    if ( written == -1 ) {
      perror("Error writing socket:");
      throw Exception("socket write error");
    }
    to_write -= written;
    ptr += written;
  } while ( to_write );

  if ( serialized_size ) {
    LOG("going to write %d bytes as serialized args\n", serialized_size);
    /* write serialized instruction args */
    to_write = serialized_size;
    ptr = (char*) i->get_serialized();
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

}

void NetOutputProcessor::_receive_reply(Instruction* i) {
  char buff[sizeof(uint32_t)]; /* only for size of serialized reply */
  /* read reply size*/
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

  /* read reply */
  uint32_t *size_ptr = (uint32_t*) buff;
  uint32_t size = *size_ptr;
  LOG("goint to read %d bytes (reply size)\n", size);
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
