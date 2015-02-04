#ifndef _CUSTOM_COMMANDS_H
#define _CUSTOM_COMMANDS_H

#include "common.h"
#include "generated.h"
#include "Instruction.h"
#include "Processor.h"

#include <SDL.h>

extern "C" const char **cglng_custom_function_names;

#define CGLNG_SDL_GETVIDEOINFO_ID (LAST_GENERATED_ID+1)
void dump_cglng_SDL_GetVideoInfo(Instruction* i, int direction);
void serializer_cglng_SDL_GetVideoInfo(Instruction* i, int direction);
void deserializer_cglng_SDL_GetVideoInfo(Instruction* i, int direction);
void exec_cglng_SDL_GetVideoInfo(Instruction *_i, void* executor);

#define LAST_CUSTOM_ID CGLNG_SDL_GETVIDEOINFO_ID

void cglng_custom_fill_packed_dumpers(void *text_functions);
void cglng_custom_fill_packed_executors(void *packed_executor_functions);


#endif /* _CUSTOM_COMMANDS_H */
