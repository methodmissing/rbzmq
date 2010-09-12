#define RUBY18
#include <rubysig.h>
#include <rubyio.h>

/* Credit to Brian Lopez and Eric Wong, leeched from mysql2 */

/*
 * partial emulation of the 1.9 rb_thread_blocking_region under 1.8,
 * this is enough for dealing with blocking I/O functions in the
 * presence of threads.
 */

#define RUBY_UBF_IO ((rb_unblock_function_t *)-1)
typedef void rb_unblock_function_t(void *);
typedef VALUE rb_blocking_function_t(void *);
static VALUE
rb_thread_blocking_region(
  rb_blocking_function_t *func, void *data1,
  RB_ZMQ_UNUSED rb_unblock_function_t *ubf,
  RB_ZMQ_UNUSED void *data2)
{
  VALUE rv;

  TRAP_BEG;
  rv = func(data1);
  TRAP_END;

  return rv;
}

/*
*  References
*  http://github.com/methodmissing/rbzmq/commit/c3da4cd14ff8be39ac3bf0f2735e3039ef806584
*  http://www.mail-archive.com/zeromq-dev@lists.zeromq.org/msg03131.html
*/

#ifdef ZMQ_FD
#define ZMQ_HOOK_FD(s) \
    int fd; \
    size_t optsiz = sizeof(fd); \
    rc = zmq_getsockopt((s), ZMQ_FD, &fd, &optsiz); \
    ZMQ_CHECK_RETURN
#define ZMQ_THREAD_WAIT rb_thread_wait_fd(fd);
#else
#define ZMQ_HOOK_FD(s)
#define ZMQ_THREAD_WAIT rb_thread_polling();
#endif

#define ZMQ_SEND_RECV_BLOCKING(func, rc, s, msg, fl) \
    ZMQ_HOOK_FD((s)) \
    if (!rb_thread_alone()){ \
      if ((fl) == 0) (fl) = (fl) | ZMQ_NOBLOCK; \
      retry: \
        (rc) = func((s), (msg), fl); \
        if ((rc) < 0) { \
          if (zmq_errno() == EAGAIN) { \
             ZMQ_THREAD_WAIT \
             goto retry; \
          } \
        } \
     }else{ \
       (rc) = func((s), (msg), fl); \
     }
#define ZMQ_SEND_BLOCKING(rc, s, msg, fl) ZMQ_SEND_RECV_BLOCKING(zmq_send, rc, s, msg, fl)
#define ZMQ_RECV_BLOCKING(rc, s, msg, fl) ZMQ_SEND_RECV_BLOCKING(zmq_recv, rc, s, msg, fl)