#
#    Copyright (c) 2007-2010 iMatix Corporation
#
#    This file is part of 0MQ.
#
#    0MQ is free software; you can redistribute it and/or modify it under
#    the terms of the Lesser GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    0MQ is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    Lesser GNU General Public License for more details.
#
#    You should have received a copy of the Lesser GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'mkmf'
dir_config('zmq')
have_func('rb_thread_blocking_region')
if have_library('zmq', 'zmq_init')
  puts "Cool, I found your zmq install..."
  $defs.push("-pedantic")
  create_makefile("zmq")
else
  raise "Couldn't find zmq library. try setting --with-zmq-dir=<path> to tell me where it is."
end


