#include "Interceptor.h"
#include "common.h"
#include <dlfcn.h>

Interceptor& Interceptor::get_instance() {
  static Interceptor instance;
  return instance;;
}

Interceptor::Interceptor(){
  original_SDL_Init = NULL;
  initial_instruction = last_instruction = NULL;
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
  initial_instruction = new Instruction(id);
  return initial_instruction;
}

void Interceptor::intercept(Instruction* i){
  vector<Instruction*> queue;
  queue.push_back(i);
  for (vector<Processor*>::iterator it = processors.begin(); it != processors.end(); it++) {
    (*it)->submit(queue);
  }
  for (vector<Instruction*>::iterator it = queue.begin(); it != queue.end(); it++) {
    if((*it)->references_count() != 1) {
      LOG("Warning, ref_count != for instruction %d\n", (*it)->id);
    }
    delete *it;
  }
}

void Interceptor::intercept_with_reply(Instruction* i){
  vector<Processor*>::iterator it;
  // advance forward
  for (it = processors.begin(); it != processors.end(); it++) {
    if ( (*it)->query(i, DIRECTION_FORWARD) ) {
      break;
    }
  }

  // advance backward
  do {
    it--;
    (*it)->query(i, DIRECTION_BACKWARD);
  } while( it != processors.begin() );

  // remove previous reply
  if (last_instruction) delete last_instruction;
  last_instruction = i;
  // return control back to capturer, with assumption that i contains
  // necessary reply
}

extern "C" int SDL_Init(unsigned int flags) {
  return Interceptor::get_instance().intercept_sdl_init(flags);
};

