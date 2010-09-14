class TestSocket < Test::Unit::TestCase
  def test_request_reply
    context do |ctx|
      req = ctx.socket ZMQ::REQ
      rep = ctx.socket ZMQ::REP
      req.bind('tcp://127.0.0.1:5554')
      rep.connect('tcp://127.0.0.1:5554')
      req.send('msq', 0)
      assert_equal 'msq', rep.recv(0)
    end
  end

  def test_pair
    context do |ctx|
      a = ctx.socket ZMQ::PAIR
      b = ctx.socket ZMQ::PAIR
      a.bind('tcp://127.0.0.1:5558')
      b.connect('tcp://127.0.0.1:5558')
      a.send('msq_a', 0)
      a.send('msq_b', 0)
      a.send('msq_c', 0)
      assert_equal 'msq_a', b.recv(0)
      assert_equal 'msq_b', b.recv(0)
      assert_equal 'msq_c', b.recv(0)
    end
  end

  def test_pub_sub
    context do |ctx|
      pub = ctx.socket ZMQ::PUB
      sub = ctx.socket ZMQ::SUB
      pub.bind('tcp://127.0.0.1:5560')
      pub.bind('inproc://test.pub.sub')
      sub.connect('inproc://test.pub.sub')
      sub.setsockopt(ZMQ::SUBSCRIBE, 'a')
      pub.send('a', 0)
      assert_equal 'a', sub.recv(0)
    end
  end

  def test_upstream_downstream
    context do |ctx|
      up = ctx.socket ZMQ::UPSTREAM
      down = ctx.socket ZMQ::DOWNSTREAM
      up.bind('tcp://127.0.0.1:5559')
      down.connect('tcp://127.0.0.1:5559')
      down.send('msq_a', 0)
      down.send('msq_b', 0)
      assert_equal 'msq_a', up.recv(0)
      assert_equal 'msq_b', up.recv(0)
    end
  end

  def test_threaded
    context do |ctx|
      req = ctx.socket ZMQ::REQ
      rep = ctx.socket ZMQ::REP
      req.bind('tcp://127.0.0.1:5553')
      rep.connect('tcp://127.0.0.1:5553')
      Thread.new{ req.send('from bg thread', 0) }
      assert_equal 'from bg thread', rep.recv(0)
    end
  end

  def test_bind
    context do |ctx|
      s = ctx.socket ZMQ::REQ
      assert_zmq_error(/Invalid argument/) do
        s.bind("XXX")
      end
      assert_equal nil, s.bind('tcp://127.0.0.1:5551')
    end
  end

  def test_connect
    context do |ctx|
      s = ctx.socket ZMQ::REQ
      assert_zmq_error(/Invalid argument/) do
        s.connect("XXX")
      end
      assert_equal nil, s.connect('tcp://127.0.0.1:5552')
    end
  end

  def test_getsockopt
    context do |ctx|
      s = ctx.socket ZMQ::REQ
      assert_equal false, s.getsockopt(ZMQ::RCVMORE)
      assert_equal 0, s.getsockopt(ZMQ::HWM)
      assert_equal 0, s.getsockopt(ZMQ::SWAP)
      assert_equal 0, s.getsockopt(ZMQ::AFFINITY)
      assert_equal "", s.getsockopt(ZMQ::IDENTITY)
      assert_equal 100, s.getsockopt(ZMQ::RATE)
      assert_equal 10, s.getsockopt(ZMQ::RECOVERY_IVL)
      assert_equal 1, s.getsockopt(ZMQ::MCAST_LOOP)
      assert_equal 0, s.getsockopt(ZMQ::SNDBUF)
      assert_equal 0, s.getsockopt(ZMQ::RCVBUF)
    end
  end

  def test_setsockopt
    context do |ctx|
      s = ctx.socket ZMQ::SUB
      s.setsockopt(ZMQ::HWM, 100)
      assert_equal 100, s.getsockopt(ZMQ::HWM)
      s.setsockopt(ZMQ::SWAP, 100)
      assert_equal 100, s.getsockopt(ZMQ::SWAP)
      s.setsockopt(ZMQ::AFFINITY, 1)
      assert_equal 1, s.getsockopt(ZMQ::AFFINITY)
      s.setsockopt(ZMQ::IDENTITY, 'id')
      assert_equal 'id', s.getsockopt(ZMQ::IDENTITY)
      s.setsockopt(ZMQ::SUBSCRIBE, 'id')
      s.setsockopt(ZMQ::UNSUBSCRIBE, 'id')
      s.setsockopt(ZMQ::RATE, 50)
      assert_equal 50, s.getsockopt(ZMQ::RATE)
      s.setsockopt(ZMQ::RECOVERY_IVL, 50)
      assert_equal 50, s.getsockopt(ZMQ::RECOVERY_IVL)
      s.setsockopt(ZMQ::MCAST_LOOP, false)
      assert_equal 0, s.getsockopt(ZMQ::MCAST_LOOP)
      s.setsockopt(ZMQ::SNDBUF, 50)
      assert_equal 50, s.getsockopt(ZMQ::SNDBUF)
      s.setsockopt(ZMQ::RCVBUF, 50)
      assert_equal 50, s.getsockopt(ZMQ::RCVBUF)
    end
  end

  def test_close
    context do |ctx|
      s = ctx.socket ZMQ::REQ
      assert_equal nil, s.close
      assert_zmq_error(/closed socket/, IOError) do
        s.send('message', 0)
      end
    end
  end
end