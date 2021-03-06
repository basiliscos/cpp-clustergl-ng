#include "Processor.h"
#include "Instruction.h"
#include "generated.h"
#include "custom_commands.h"

TextProcessor::TextProcessor(){
  text_functions = (void**) malloc(sizeof(void*) * (LAST_CUSTOM_ID+1));
  if (!text_functions) {
    LOG("Cannot allocate memory for executor functions, exiting\n");
    abort();
  }
  cglng_fill_packed_dumpers(text_functions);
  CGLNG_directed_function *ptr = (CGLNG_directed_function*) text_functions;
  cglng_custom_fill_packed_dumpers(ptr + LAST_GENERATED_ID + 1);
}

TextProcessor::~TextProcessor() {
  free(text_functions);
}

bool TextProcessor::is_terminal() { return false; }

bool TextProcessor::submit(vector<Instruction* > &queue) {
  if (queue.size() > 1 ) {
    LOG("instuction queue lenght: %lu\n", queue.size());
  }
  for (vector<Instruction*>::iterator it = queue.begin(); it != queue.end(); it++) {
    Instruction* i = *it;
    uint32_t id = i->id;
    if (id > LAST_CUSTOM_ID ) {
      LOG("Unknown instruction id: %u, aborting...\n", id);
      abort();
    }
    CGLNG_simple_function f = (CGLNG_simple_function) text_functions[id];
    f(i);
  }
}

bool TextProcessor::query(Instruction* i, int direction) {
    uint32_t id = i->id;
    if (id > LAST_CUSTOM_ID ) {
      LOG("Unknown query instruction id: %u, aborting...\n", id);
      abort();
    }
    CGLNG_directed_function f = (CGLNG_directed_function) text_functions[id];
    f(i, direction);
    return false;
}
