/*
    Copyright (c) 2007-2010 iMatix Corporation

    This file is part of 0MQ.

    0MQ is free software; you can redistribute it and/or modify it under
    the terms of the Lesser GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    0MQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    Lesser GNU General Public License for more details.

    You should have received a copy of the Lesser GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <assert.h>
#include <string.h>
#include <ruby.h>
#ifdef HAVE_RUBY_IO_H
#include <ruby/io.h>
#else
#include <rubyio.h>
#endif
#include <zmq.h>

#if defined _MSC_VER
#ifndef int8_t
typedef __int8 int8_t;
#endif
#ifndef int16_t
typedef __int16 int16_t;
#endif
#ifndef int32_t
typedef __int32 int32_t;
#endif
#ifndef int64_t
typedef __int64 int64_t;
#endif
#ifndef uint8_t
typedef unsigned __int8 uint8_t;
#endif
#ifndef uint16_t
typedef unsigned __int16 uint16_t;
#endif
#ifndef uint32_t
typedef unsigned __int32 uint32_t;
#endif
#ifndef uint64_t
typedef unsigned __int64 uint64_t;
#endif
#else
#include <stdint.h>
#endif

#define Check_Socket(__socket) \
    do {\
        if ((__socket) == NULL)\
            rb_raise (rb_eIOError, "closed socket");\
    } while(0)

#define ZMQ_ERROR rb_raise(rb_eRuntimeError, "%s", zmq_strerror (zmq_errno ()));

#define GET_ZMQ_SOCKET \
    void * s; \
    Data_Get_Struct (self_, void, s); \
    Check_Socket (s);

#if defined(__GNUC__) && (__GNUC__ >= 3)
#define RB_ZMQ_UNUSED __attribute__ ((unused))
#else
#define RB_ZMQ_UNUSED
#endif

/* Credit to Brian Lopez and Eric Wong, leeched from mysql2 */

/*
 * partial emulation of the 1.9 rb_thread_blocking_region under 1.8,
 * this is enough for dealing with blocking I/O functions in the
 * presence of threads.
 */

#ifndef HAVE_RB_THREAD_BLOCKING_REGION

#include <rubysig.h>
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

#endif /* ! HAVE_RB_THREAD_BLOCKING_REGION */