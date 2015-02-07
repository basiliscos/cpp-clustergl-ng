#ifndef _CUSTOM_COMMANDS_H
#define _CUSTOM_COMMANDS_H

#include "common.h"
#include "generated.h"
#include "Instruction.h"
#include "Processor.h"

#include <SDL.h>

extern "C" const char **cglng_custom_function_names;

#define CGLNG_MAKE_WINDOW_ID (LAST_GENERATED_ID+1)
Instruction* packed_cglng_MakeWindow(int32_t x, int32_t y, int32_t width, int32_t height);
void dump_cglng_MakeWindow(Instruction* i, int direction);
void serializer_cglng_MakeWindow(Instruction* i, int direction);
void deserializer_cglng_MakeWindow(Instruction* i, int direction);
void exec_cglng_MakeWindow(Instruction *_i, void* executor);

#define LAST_CUSTOM_ID CGLNG_MAKE_WINDOW_ID

void cglng_custom_fill_packed_dumpers(void *text_functions);
void cglng_custom_fill_packed_executors(void *packed_executor_functions);
void cglng_custom_fill_deserializers(void *functions);

#endif /* _CUSTOM_COMMANDS_H */
