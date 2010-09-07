class TestZmq < Test::Unit::TestCase
  def test_version
    assert_instance_of Array, ZMQ.version
    assert_equal 3, ZMQ.version.size
  end

  def test_select
    ctx = ZMQ::Context.new
    req = ctx.socket ZMQ::REQ
    rep = ctx.socket ZMQ::REP
    req.bind('tcp://127.0.0.1:5555')
    rep.connect('tcp://127.0.0.1:5555')
    msg = 'message'
    req.send(msg, 0)
    rep.recv(0)
    assert_equal [[], [rep], []], ZMQ.select([req], [rep], [])
  end
end