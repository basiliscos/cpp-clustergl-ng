#ifndef _PROCESSOR_H
#define _PROCESSOR_H

#include "common.h"
#include "Instruction.h"

#define DIRECTION_FORWARD  1
#define DIRECTION_BACKWARD 2

class Processor {
 public:
    /*
       Performs Instruction submission.

       It can append/prepend queue view new instuctions, remove from queue,
       delete and modify existing ones.

       Instuction deletion is allowed only there is only 1 reference to it.

       Returns bool value, which should indicate wether the queue should be
       processed by next Processor.
    */
    virtual bool submit(vector<Instruction* > &queue) = 0;

    /*
       Submits instuction wich requires answer.

       Direction defines, when instuction in been moving towards terminator
       (DIRECTION_FORWARD) or is been returning back (DIRECTION_BACKWARD).

       When instruction is been moving forward, the processor should response,
       wether it was proccessed (true), and the instruction will not travel
       further, but will go in the opposite direction

    */
    virtual bool query(Instruction* i, int direction) = 0;

    /*
      Used to distinquish terminal processors, i.e. that ones wich finally
      consume instructions. There must be exactly one terminal node
      on pipe
    */
    virtual bool is_terminal() = 0;
};

/* just dumps packed commands */
class TextProcessor: public Processor {
 private:
  void** text_functions;
 public:
  TextProcessor();
  ~TextProcessor();

  bool submit(vector<Instruction* > &queue);
  bool query(Instruction* i, int direction);
  bool is_terminal();
};

/* executes packed commands */
class ExecProcessor: public Processor {
 private:
  void** executor_functions;
  void** packed_executor_functions;
  void* _get_executor(uint32_t id);
 public:
  ExecProcessor();
  ~ExecProcessor();

  bool submit(vector<Instruction* > &queue);
  bool query(Instruction* i, int direction);
  bool is_terminal();
};

/*
   "multiplies" instructions between local
   executor and NetOutputProcessors
*/
class NetTierProcessor: public Processor {
 private:
  ExecProcessor* exec;
 public:
  NetTierProcessor(cfg_t *global_config);
  ~NetTierProcessor();

  bool submit(vector<Instruction* > &queue);
  bool query(Instruction* i, int direction);
  bool is_terminal();
};

class NetOutputProcessor: public Processor {
 private:
  int _output;
  void _send_instruction(Instruction* i); /* serialized */
  void _receive_reply(Instruction* i);
 public:
  NetOutputProcessor(cfg_t *global_config, cfg_t *my_config, int socket);
  ~NetOutputProcessor();

  bool submit(vector<Instruction* > &queue);
  bool query(Instruction* i, int direction);
  bool is_terminal();
};

#endif /* _PROCESSOR_H */
