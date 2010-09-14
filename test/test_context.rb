class TestContext < Test::Unit::TestCase
  def test_initialize
    assert_zmq_error(/Invalid argument/) do
      ZMQ::Context.new(-1)
    end
    assert_context :threads => nil
    assert_context :threads => 0
    assert_context :threads => 2
  end

  def test_socket
    context do |ctx|
      req = ctx.socket(ZMQ::REQ)
      assert_instance_of ZMQ::Socket, req
      assert_raises TypeError do
        ctx.socket(nil)
      end
    end
  end

  def test_close
    context do |ctx|
      assert_equal nil, ctx.close
      assert_zmq_error(/Bad address/) do
        ctx.socket ZMQ::REQ
      end
    end
  end

  private
  def assert_context(opts)
    ctx = ZMQ::Context.new(opts[:threads])
    assert_instance_of ZMQ::Context, ctx
    ctx.close
  end
end