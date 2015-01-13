#ifndef _PROCESSOR_H
#define _PROCESSOR_H

#include "common.h"
#include "Instruction.h"

#define DIRECTION_FORWARD  = 1
#define DIRECTION_BACKWARD = 2

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
};

#endif /* _PROCESSOR_H */
