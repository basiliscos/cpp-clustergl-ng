#include "Processor.h"
#include "Instruction.h"
#include "generated.h"
#include "custom_commands.h"

#include <dlfcn.h>

ExecProcessor::ExecProcessor() {
  executor_functions = (void**) malloc(sizeof(void*) * (LAST_GENERATED_ID + 1) );
  if (!executor_functions) {
    LOG("Cannot allocate memory for executor functions, exiting\n");
    abort();
  }
  memset(executor_functions, 0, sizeof(void*) * (LAST_GENERATED_ID + 1) );

  packed_executor_functions = (void**) malloc(sizeof(void*) * (LAST_CUSTOM_ID + 1) );
  if (!packed_executor_functions) {
    LOG("Cannot allocate memory for packed executor functions, exiting\n");
    abort();
  }
  cglng_fill_packed_executors(packed_executor_functions);
  CGLNG_executor_function* custom_ptr = (CGLNG_executor_function*) packed_executor_functions;
  cglng_custom_fill_packed_executors( custom_ptr + LAST_GENERATED_ID + 1 );
}

ExecProcessor::~ExecProcessor() {
  free(executor_functions);
  free(packed_executor_functions);
}

bool ExecProcessor::is_terminal() { return true; }

void* ExecProcessor::_get_executor(uint32_t id) {
  const char* name = cglng_function_names[id];
  LOG("Looking for symbol: %s\n", name);
  void* executor = dlsym(RTLD_NEXT, name);
  if(!executor) {
    LOG("Warning: cannot find local symbol: %s, aborting...\n", name);
    abort();
  }
  return executor;
}


bool ExecProcessor::submit(vector<Instruction* > &queue) {
  for (vector<Instruction*>::iterator it = queue.begin(); it != queue.end(); it++) {
    Instruction* i = *it;
    uint32_t id = i->id;
    if (id > LAST_CUSTOM_ID ) {
      LOG("Unknown instruction id: %u, aborting...\n", id);
      abort();
    }
    void *executor = NULL;
    // executors are needed only for generated functions
    if ( !(i->flags & INSTRUCTION_CUSTOM)) {
      executor = executor_functions[id];
      if (!executor) {
        executor = _get_executor(id);
        executor_functions[id] = executor;
      }
    }
    CGLNG_executor_function packed_exec = (CGLNG_executor_function) packed_executor_functions[id];
    (*packed_exec)(i, executor);
  }
}

bool ExecProcessor::query(Instruction* i, int direction) {
    uint32_t id = i->id;
    if (id > LAST_CUSTOM_ID ) {
      LOG("Unknown query instruction id: %u, aborting...\n", id);
      abort();
    }
    void *executor = NULL;
    // executors are needed only for generated functions
    if ( !(i->flags & INSTRUCTION_CUSTOM)) {
      executor = executor_functions[id];
      if (!executor) {
        executor = _get_executor(id);
        executor_functions[id] = executor;
      }
    }
    CGLNG_executor_function packed_exec = (CGLNG_executor_function) packed_executor_functions[id];
    (*packed_exec)(i, executor);
    return true; // processor-terminator
}
