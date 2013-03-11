require 'test_helper'

class MessageStreamTest < ActiveSupport::TestCase
  setup do
    @stream = FactoryGirl.build(:message_stream)
  end

  test "valid message stream should be valid" do
    assert @stream.valid?
  end

  #----------------------------------------------------------------------------#
  # messages:
  #----------
  test "can associate multiple messages with a message stream" do
    assert_difference('@stream.messages.size', 2) do
      2.times do
        message = FactoryGirl.build(:message, :message_stream => @stream)
        @stream.messages << message
      end
    end
  end

  test "messages should be ordered by offset_days then by name" do
    @stream.save!
    [[2, 'n4'], [2, 'n2'], [2, 'n8'], [0, 'n1'], [9, 'n3']].map do |offset_days,name|
      FactoryGirl.create(:message,
        :message_stream => @stream,
        :name => name,
        :offset_days => offset_days
      )
    end

    actual = @stream.messages.map {|m| [m.offset_days, m.name] }
    expected = [[0, 'n1'], [2, 'n2'], [2, 'n4'], [2, 'n8'], [9, 'n3']]
    assert_equal expected, actual
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
    FactoryGirl.create(:message_stream, :name => 'mystream')
    @stream.name = 'mystream'
    assert @stream.invalid?
    assert @stream.errors[:name].any?
  end

  #----------------------------------------------------------------------------#
  # scopes:
  #--------
  test "should be sorted by name in ascending order" do
    ['w','b','e','x','n'].each do |name|
      FactoryGirl.create(:message_stream, :name => name)
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
