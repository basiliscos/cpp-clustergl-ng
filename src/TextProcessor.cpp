#include "Processor.h"
#include "Instruction.h"
#include "generated.h"

TextProcessor::TextProcessor(){
  text_functions = (void**) malloc(sizeof(void*) * LAST_GENERATED_ID);
  fill_text_dumpers(text_functions);
}

TextProcessor::~TextProcessor() {
  delete text_functions;
}

bool TextProcessor::submit(vector<Instruction* > &queue) {
  if (queue.size() > 1 ) {
    LOG("instuciton queue lenght: %lu\n", queue.size());
  }
  for (vector<Instruction*>::iterator it = queue.begin(); it != queue.end(); it++) {
    Instruction* i = *it;
    CGLNG_simple_function f = (CGLNG_simple_function) text_functions[i->id];
    f(i);
  }
}
