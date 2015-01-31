#include "Processor.h"
#include "Instruction.h"
#include "common.h"

static char* host_port = NULL;

void _print_help_and_exit(char** argv) {
  printf("invocation: %s host:port identity\n", argv[0]);
  if(host_port) free(host_port);
  exit(1);
}

int main(int argc, char** argv) {
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
  /*
  if (inet_aton(host_port, &serv_addr.sin_addr) == 0) {
    perror("inet_aton() error");
    exit(1);
  }
  */
  if(serv_addr.sin_addr.s_addr == INADDR_NONE) {
    printf("wrong address\n");
    exit(1);
  }

  int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
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

  return 0;
}
