#include "Processor.h"

#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

NetTierProcessor::NetTierProcessor(cfg_t *global_config) {
  cfg_t *my_config = cfg_getsec(global_config, "net_tier");
  int listen_port = cfg_getint(my_config, "listen_port");
  int output_count = cfg_size(my_config, "output");
  int sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0) {
    perror("opening socket error: ");
    exit(1);
  }
  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = INADDR_ANY;
  serv_addr.sin_port = htons(listen_port);
  if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0){
    perror("socket bind error: ");
    exit(1);
  }
  if (listen(sockfd,5) ) {
    perror("socket listen error: ");
    exit(1);
  }
  LOG("net_tier is going to wait %d nodes on %d port ...\n", output_count, listen_port);

  int actual_nodes = 0;
  /*
     negotiation protocol:
     1. read identity length
     2. read indentity (up-to 100 symbols)
     3. if identity presents among outputs - accept it
   */ 
  do {
    char buff[100];
    struct sockaddr_in cli_addr;
    memset(buff, 0, 100);
    socklen_t cli_len = sizeof(cli_addr);
    int client_fd = accept(sockfd, (struct sockaddr *) &cli_addr, &cli_len);
    if ( client_fd < 0 ) {
      perror("accept error: ");
      continue;
    }
    LOG("%s connected\n", inet_ntoa(cli_addr.sin_addr));
    uint32_t identity_length = 0;
    int read_bytes = read(client_fd, &identity_length, sizeof(uint32_t));
    if ( read_bytes == sizeof(uint32_t) && identity_length > 0 && identity_length < 100 ) {
      read_bytes = read(client_fd, buff, identity_length);
      if ( read_bytes > 0 &&  ((uint32_t) read_bytes) == identity_length ) {
        for (int i = 0; i < output_count; i++) {
          cfg_t *output_cfg = cfg_getnsec(my_config, "output", i);
          char* output_identity = cfg_getstr(output_cfg, "identity");
          if ( strncmp(buff, output_identity, identity_length) == 0 ) {
            LOG("Connected %s node\n", output_identity);
            actual_nodes++;
          }
        }
      }
    }
  } while(actual_nodes < output_count);
}

NetTierProcessor::~NetTierProcessor() {
}

bool NetTierProcessor::is_terminal(){ return true; }

bool NetTierProcessor::submit(vector<Instruction* > &queue) {
  abort();
}

bool NetTierProcessor::query(Instruction* i, int direction) {
  abort();
}