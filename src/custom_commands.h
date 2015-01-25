#ifndef _CUSTOM_COMMANDS_H
#define _CUSTOM_COMMANDS_H

#include "common.h"
#include "generated.h"
#include "Instruction.h"

#include <SDL.h>

#define CGLNG_SDL_GETVIDEOINFO_ID (LAST_GENERATED_ID+1)
void dump_cglng_SDL_GetVideoInfo(Instruction* i);
void serializer_cglng_SDL_GetVideoInfo(Instruction* i);
void deserializer_cglng_SDL_GetVideoInfo(Instruction* i);
void exec_cglng_SDL_GetVideoInfo(Instruction *_i, void* executor);

void cglng_custom_fill_packet_dumpers(void *text_functions);
void cglng_custom_fill_packed_executors(void *packed_executor_functions);


#endif /* _CUSTOM_COMMANDS_H */
