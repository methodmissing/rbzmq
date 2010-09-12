#define RUBY19
#include <ruby/io.h>
#include <ruby/backward/rubysig.h>
#define ZMQ_SEND_BLOCKING(rc, s, msg, fl) (rc) = zmq_send((s), (msg), (fl));
#define ZMQ_RECV_BLOCKING(rc, s, msg, fl) (rc) = zmq_recv((s), (msg), (fl));