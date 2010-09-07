$:.unshift "."
require 'ext/rbzmq/zmq'
require 'test/unit'

class Test::Unit::TestCase
  def assert_zmq_error(rgx, err = RuntimeError)
    yield
  rescue err => e
    assert_match(rgx, e.to_s)
  end
end