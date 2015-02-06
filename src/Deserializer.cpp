#include "Processor.h"
#include "common.h"
#include "custom_commands.h"

Deserializer::Deserializer() {
  deserialize_functions = (void**) malloc(sizeof(void*) * (LAST_CUSTOM_ID + 1) );
  if (!deserialize_functions) {
    LOG("Cannot allocate memory for deserialize functions, exiting\n");
    abort();
  }
  /* fill generated deserializers */
  CGLNG_executor_function* custom_ptr = (CGLNG_executor_function*) deserialize_functions;
  cglng_custom_fill_deserializers( custom_ptr + LAST_GENERATED_ID + 1 );
}

Deserializer::~Deserializer() {
  free(deserialize_functions);
}

bool Deserializer::submit(vector<Instruction* > &queue) {
  for (vector<Instruction*>::iterator it = queue.begin(); it != queue.end(); it++) {
    Instruction* i = *it;
    uint32_t id = i->id;
    if (id > LAST_CUSTOM_ID ) {
      LOG("Unknown instruction id: %u, aborting...\n", id);
      abort();
    }
    CGLNG_simple_function deserializer = (CGLNG_simple_function) deserialize_functions[id];
    (*deserializer)(i);
  }
}

bool Deserializer::query(Instruction* i, int direction) {
  uint32_t id = i->id;
  if (id > LAST_CUSTOM_ID ) {
    LOG("Unknown query instruction id: %u, aborting...\n", id);
    abort();
  }
  CGLNG_directed_function deserializer = (CGLNG_directed_function) deserialize_functions[id];
  (*deserializer)(i, direction);
  return false;
}

bool Deserializer::is_terminal() { return false; }
