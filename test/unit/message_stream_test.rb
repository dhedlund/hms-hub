require 'test_helper'

class MessageStreamTest < ActiveSupport::TestCase
  setup do
    @stream = Factory.build(:message_stream)
  end

  test "valid message stream should be valid" do
    assert @stream.valid?
  end

  #----------------------------------------------------------------------------#
  # delivery_method:
  #-----------------
  test "should be invalid without a delivery_method" do
    @stream.delivery_method = nil
    assert @stream.invalid?
    assert @stream.errors[:delivery_method].any?
  end

  #----------------------------------------------------------------------------#
  # messages:
  #----------
  test "can associate multiple messages with a message stream" do
    assert_difference('@stream.messages.size', 2) do
      2.times do
        message = Factory.build(:message, :message_stream => @stream)
        @stream.messages << message
      end
    end
  end

  #----------------------------------------------------------------------------#
  # language:
  #----------
  test "should be valid without a language" do
    @stream.language = nil
    assert @stream.valid?
  end

  #----------------------------------------------------------------------------#
  # name:
  #------
  test "should be invalid without a name" do
    @stream.name = nil
    assert @stream.invalid?
    assert @stream.errors[:name].any?
  end

  test "cannot have two message streams with the same name" do
    Factory.create(:message_stream, :name => 'mystream')
    @stream.name = 'mystream'
    assert @stream.invalid?
    assert @stream.errors[:name].any?
  end

  #----------------------------------------------------------------------------#
  # program:
  #---------
  test "can access program from message_stream" do
    assert @stream.program
  end


  #----------------------------------------------------------------------------#
  # scopes:
  #--------
  test "should be sorted by name in ascending order" do
    ['w','b','e','x','n'].each do |name|
      Factory.create(:message_stream, :name => name)
    end
    assert_equal MessageStream.all.map(&:name).sort, MessageStream.all.map(&:name)
  end

  #----------------------------------------------------------------------------#
  # title:
  #-------
  test "should be invalid without a title" do
    @stream.title = nil
    assert @stream.invalid?
    assert @stream.errors[:title].any?
  end

end
