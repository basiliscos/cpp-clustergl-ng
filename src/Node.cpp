#include "Node.h"

void Node::_print_help_and_exit(char** argv) {
  printf("invocation: %s host:port identity\n", argv[0]);
  if(host_port) free(host_port);
  exit(1);
}

Node::Node(int argc, char** argv) {
  if (argc != 3) _print_help_and_exit(argv);
  uint32_t host_port_size = strlen(argv[1]);
  host_port = (char*) malloc( host_port_size + 1);
  if (!host_port) {
    LOG("memory allocation failed\n");
    exit(1);
  }
  memcpy(host_port, argv[1], host_port_size);
  host_port[host_port_size] = 0;
  char* identity = argv[2];
  char* port_str = strchr(host_port, ':');
  if (!port_str) _print_help_and_exit(argv);
  *port_str++ = 0;
  int port = atoi(port_str);

  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(port);
  serv_addr.sin_addr.s_addr = inet_addr(host_port);
  if (inet_aton(host_port, &serv_addr.sin_addr) == 0) {
    perror("inet_aton() error");
    exit(1);
  }

  socket_fd = socket(AF_INET, SOCK_STREAM, 0);
  if ( socket_fd < 0) {
      perror("socket() error");
      exit(1);
  }
  LOG("Connecting to %s:%d, identifying self as \"%s\"\n", host_port, port, argv[2]);
  if (connect(socket_fd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
    perror("connecting error");
    close(socket_fd);
    exit(1);
  }
  LOG("Connected, sending identity\n");
  uint32_t identity_length = strlen(argv[2]);
  uint32_t bytes_to_write = sizeof(uint32_t);
  char* write_ptr = (char*)&identity_length;
  /* send identity_length */
  do {
    int written = write(socket_fd, write_ptr, bytes_to_write);
    if (written < 0 ) {
      perror("write() error");
      exit(1);
    }
    bytes_to_write -= written;
    write_ptr += written;
  } while (bytes_to_write);

  bytes_to_write = identity_length;
  write_ptr = argv[2];
  /* send identity */
  do {
    int written = write(socket_fd, write_ptr, bytes_to_write);
    if (written < 0 ) {
      perror("write() error");
      exit(1);
    }
    bytes_to_write -= written;
    write_ptr += written;
  } while (bytes_to_write);
  char buff[1];
  int got_bytes = read(socket_fd, buff, 1);
  if ( got_bytes < 1 ) {
    perror("read() error");
    exit(1);
  }
  if (!buff[0]) {
    LOG("Remote side did not confirmed connection, exiting\n");
    exit(1);
  }

  LOG("OK, remote side confirmed connection\n");
  all_processors.push_back(new ExecProcessor());
}

Node::~Node(){
  if (socket_fd) close(socket_fd);
  if (host_port) free(host_port);
  for (uint32_t i = 0; i < all_processors.size(); i++) {
    delete all_processors[i];
  }
}

Instruction* Node::_receive() {
  LOG("going to receive instruction from socket\n");
  char buff[sizeof(uint32_t)*2+1];
  uint32_t to_read = sizeof(uint32_t)*2+1;
  char* ptr = buff;
  LOG("going to read %d bytes\n", to_read);
  do {
    int got_bytes = read(socket_fd, ptr, to_read);
    if (got_bytes < 0) {
      perror("read() error");
      throw Exception("socket read error");
    }
    ptr += got_bytes;
    to_read -= got_bytes;
  } while (to_read);
  uint32_t*  uint32_t_ptr = (uint32_t*) buff;
  //TODO: check that instuciton_id belongs to our range
  uint32_t instruction_id = *uint32_t_ptr++;
  LOG("received instruction %d\n", instruction_id);
  ptr = (char*) uint32_t_ptr;
  unsigned char flags = *ptr++;
  uint32_t_ptr = (uint32_t*) ptr;
  uint32_t args_size = *uint32_t_ptr++;

  Instruction *i = new Instruction(instruction_id, flags);
  ptr = (char*) i->serialize_allocate(args_size);
  to_read = args_size;
  LOG("going to read %d bytes (instuction arguments)\n", to_read);
  while(to_read) {
    int got_bytes = read(socket_fd, ptr, to_read);
    if (got_bytes < 0) {
      perror("read() error");
      throw Exception("socket read error");
    }
    ptr += got_bytes;
    to_read -= got_bytes;
  }
  return i;
}

void Node::execution_loop() {
  while(true) {
    Instruction* i = _receive();
    LOG("processing instruction %d\n", i->id);
    vector<Instruction*> queue;
    queue.push_back(i);
    if(i->flags & INSTRUCTION_NEED_REPLY) {
      unsigned int idx = 0;
      // advance forward
      for (idx = 0; idx < all_processors.size(); idx++) {
        if ( all_processors[idx]->query(i, DIRECTION_FORWARD) ) {
          break;
        }
      }

      // advance backward
      if (idx) {
        do {
          all_processors[--idx]->query(i, DIRECTION_BACKWARD);
        } while( idx );
      };

      i->release();
    }
  }
}

int main(int argc, char** argv) {
  Node* node = new Node(argc, argv);
  LOG("Starting main execution loop\n");
  node->execution_loop();
  return 0;
}
