#include "Processor.h"
#include "Instruction.h"
#include "generated.h"

TextProcessor::TextProcessor(){
  text_functions = (void**) malloc(sizeof(void*) * LAST_GENERATED_ID);
  if (!text_functions) {
    LOG("Cannot allocate memory for executor functions, exiting\n");
    abort();
  }
  cglng_fill_packet_dumpers(text_functions);
}

TextProcessor::~TextProcessor() {
  free(text_functions);
}

bool TextProcessor::submit(vector<Instruction* > &queue) {
  if (queue.size() > 1 ) {
    LOG("instuction queue lenght: %lu\n", queue.size());
  }
  for (vector<Instruction*>::iterator it = queue.begin(); it != queue.end(); it++) {
    Instruction* i = *it;
    uint32_t id = i->id;
    if (id > LAST_GENERATED_ID ) {
      LOG("Unknown instruction id: %u, aborting...\n", id);
      abort();
    }
    CGLNG_simple_function f = (CGLNG_simple_function) text_functions[id];
    f(i);
  }
}

bool TextProcessor::query(Instruction* i, int direction) {
    uint32_t id = i->id;
    if (id > LAST_GENERATED_ID ) {
      LOG("Unknown query instruction id: %u, aborting...\n", id);
      abort();
    }
    CGLNG_directed_function f = (CGLNG_directed_function) text_functions[id];
    f(i, direction);
    return false;
}
