#include "Processor.h"
#include "Instruction.h"
#include "generated.h"
#include <dlfcn.h>

ExecProcessor::ExecProcessor() {
  executor_functions = (void**) malloc(sizeof(void*) * LAST_GENERATED_ID);
}

ExecProcessor::~ExecProcessor() {
  free(executor_functions);
}

bool ExecProcessor::submit(vector<Instruction* > &queue) {
  for (vector<Instruction*>::iterator it = queue.begin(); it != queue.end(); it++) {
    Instruction* i = *it;
    uint32_t id = i->id;
    if (id > LAST_GENERATED_ID ) {
      LOG("Unknown instruction id: %u, aborting...\n", id);
      abort();
    }
    void *executor = executor_functions[id];
    if (!executor) {
      const char* name = cglng_function_names[id];
      LOG("Looking for symbol: %s\n", name);
      executor = dlsym(RTLD_NEXT, name);
      if(!executor) {
        LOG("Warning: cannot find local symbol: %s, aborting...\n", name);
        abort();
      }
      executor_functions[id] = executor;
    }
  }
}
