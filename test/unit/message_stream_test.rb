require 'test_helper'

class MessageStreamTest < ActiveSupport::TestCase
  test "valid message stream should be valid" do
    assert Factory.build(:message_stream).valid?
  end

  test "should be invalid without a name" do
    assert Factory.build(:message_stream, :name => nil).invalid?
  end

  test "should be invalid without a title" do
    assert Factory.build(:message_stream, :title => nil).invalid?
  end

  test "cannot have two message streams with the same name" do
    Factory.create(:message_stream, :name => 'mystream')
    assert Factory.build(:message_stream, :name => 'mystream').invalid?
  end

end
