class TestContext < Test::Unit::TestCase
  def test_initialize
    ctx = ZMQ::Context.new
    assert_instance_of ZMQ::Context, ctx
    ctx = ZMQ::Context.new(2)
    assert_instance_of ZMQ::Context, ctx
  end

  def test_socket
    ctx = ZMQ::Context.new
    req = ctx.socket ZMQ::REQ
    assert_instance_of ZMQ::Socket, req
  end

  def test_close
    ctx = ZMQ::Context.new
    ctx.close
    assert_zmq_error(/Bad address/) do
      ctx.socket ZMQ::REQ
    end
  end
end