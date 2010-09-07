class TestSocket < Test::Unit::TestCase
  def test_send_receive
    ctx = ZMQ::Context.new
    req = ctx.socket ZMQ::REQ
    rep = ctx.socket ZMQ::REP
    req.bind('tcp://127.0.0.1:5554')
    rep.connect('tcp://127.0.0.1:5554')
    req.send('msq', 0)
    assert_equal 'msq', rep.recv(0)
  end

  def test_send_receive_threaded
    ctx = ZMQ::Context.new
    req = ctx.socket ZMQ::REQ
    rep = ctx.socket ZMQ::REP
    req.bind('tcp://127.0.0.1:5553')
    rep.connect('tcp://127.0.0.1:5553')
    Thread.new{ req.send('from bg thread', 0) }
    assert_equal 'from bg thread', rep.recv(0)
  end

  def test_bind
    ctx = ZMQ::Context.new
    req = ctx.socket ZMQ::REQ
    assert_zmq_error(/Invalid argument/) do
      req.bind("XXX")
    end
    assert_equal nil, req.bind('tcp://127.0.0.1:5551')
  end

  def test_connect
    ctx = ZMQ::Context.new
    req = ctx.socket ZMQ::REQ
    assert_zmq_error(/Invalid argument/) do
      req.connect("XXX")
    end
    assert_equal nil, req.connect('tcp://127.0.0.1:5552')
  end

  def test_close
    ctx = ZMQ::Context.new
    req = ctx.socket ZMQ::REQ
    req.close
    assert_zmq_error(/closed socket/, IOError) do
      req.send('message', 0)
    end
  end
end