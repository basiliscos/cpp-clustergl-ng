#include "Exception.h"
#include "Instruction.h"
#include "Processor.h"
#include "common.h"

class Node {
 private:
  char* host_port;
  int socket_fd;
  void _print_help_and_exit(char** argv);
  vector<Processor*> all_processors;
  Instruction* _receive();
 public:
  Node(int argc, char** argv);
  ~Node();
  void execution_loop();
};
