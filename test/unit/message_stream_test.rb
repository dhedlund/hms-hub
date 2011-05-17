require 'test_helper'

class MessageStreamTest < ActiveSupport::TestCase
  setup do
    @stream = MessageStream.new(:name => 'stream1', :title => 'Stream 1')
  end

  test "valid message stream should be valid" do
    assert @stream.valid?
  end

  test "invalid message stream should be invalid" do
    stream = MessageStream.new
    assert stream.invalid?
  end

  test "should be invalid without a name" do
    @stream.name = nil
    assert @stream.invalid?
  end

  test "should be invalid without a title" do
    @stream.title = nil
    assert @stream.invalid?
  end

  test "cannot have two message streams with the same name" do
    @stream.save
    @dupe_stream = @stream.clone
    assert @dupe_stream.invalid?
  end

end
