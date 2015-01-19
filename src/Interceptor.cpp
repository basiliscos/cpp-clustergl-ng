#include "Interceptor.h"
#include "common.h"
#include <dlfcn.h>

Interceptor& Interceptor::get_instance() {
  static Interceptor instance;
  return instance;
}

Interceptor::Interceptor(){
  original_SDL_Init = NULL;
  initial_instruction = last_instruction = NULL;

  char* config_file = getenv("CGLNG_CONFIG");
  if (!config_file) {
    LOG("No config file defined via CGLNG_CONFIG, exiting ...\n");
    exit(1);
  }
  cfg_opt_t output_opts[] = {
    CFG_STR( (char *)("identity"), 0, CFGF_NONE),
    CFG_INT( (char *)("size_x"), 0, CFGF_NONE),
    CFG_INT( (char *)("size_y"), 0, CFGF_NONE),
    CFG_INT( (char *)("position_x"), 0, CFGF_NONE),
    CFG_INT( (char *)("position_y"), 0, CFGF_NONE),
    CFG_INT( (char *)("offset_x"), 0, CFGF_NONE),
    CFG_INT( (char *)("offset_x"), 0, CFGF_NONE),
    CFG_END()
  };
  cfg_opt_t net_tier_opts[] = {
    CFG_INT( (char *)("listen_port"), 0, CFGF_NONE),
    CFG_SEC( (char *)"output", output_opts, CFGF_MULTI),
    CFG_END()
  };

  cfg_opt_t opts[] = {
    CFG_STR_LIST( (char *)"capture_pipeline", (char *)"{}", CFGF_NONE),
    CFG_SEC( (char *)"net_tier", net_tier_opts, CFGF_NONE),
    CFG_END()
  };

  cfg_t *cfg = cfg_init(opts, 0);
  switch(cfg_parse(cfg, config_file)) {
  case CFG_FILE_ERROR:
    LOG("Warning: configuration file '%s' could not be read: %s, exiting...\n",
           config_file, strerror(errno));
    exit(1);
  case CFG_SUCCESS:
    break;
  case CFG_PARSE_ERROR:
    LOG("Error parsing config %s, exiting...\n", config_file);
    exit(1);
  }
  for(unsigned int i = 0; i < cfg_size(cfg, "capture_pipeline"); i++){
    string module_name(cfg_getnstr(cfg, "capture_pipeline", i));
    Processor* p = NULL;
    if (module_name == "text") p = new TextProcessor();
    else if (module_name == "exec") p = new ExecProcessor();
    if (p) {
      LOG("using %s processor\n", module_name.c_str());
      processors.push_back(p);
    }
  }
  if (processors.size() == 0) {
    LOG("No, processors have been in configuration, exiting...\n");
    exit(1);
  }
  uint32_t terminals = 0;
  for(unsigned int i = 0; i < processors.size(); i++) {
    if (processors[i]->is_terminal() ) terminals++;
  }
  if (terminals == 0) {
    LOG("No, terminal processor found in configuration, exiting...\n");
    exit(1);
  }
  if (terminals > 1) {
    LOG("There should be only one terminal processor, exiting...\n");
    exit(1);
  }
  LOG("Inteceptor has been successfuly initialized\n");
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
    (*it)->release();
    delete *it;
  }
}

void Interceptor::intercept_with_reply(Instruction* i){
  unsigned int idx = 0;
  // advance forward
  for (idx = 0; idx < processors.size(); idx++) {
    if ( processors[idx]->query(i, DIRECTION_FORWARD) ) {
      break;
    }
  }

  // advance backward
  do {
    processors[idx]->query(i, DIRECTION_BACKWARD);
    if (!idx) break;
  } while( !idx-- );

  i->release();
  // remove previous reply
  if (last_instruction) delete last_instruction;
  last_instruction = i;
  // return control back to capturer, with assumption that i contains
  // necessary reply
}

extern "C" int SDL_Init(unsigned int flags) {
  return Interceptor::get_instance().intercept_sdl_init(flags);
};
