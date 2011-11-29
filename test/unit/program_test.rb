require 'test_helper'

class ProgramTest < ActiveSupport::TestCase
  setup do
    @program = Factory.build(:program)
  end

  test "valid program should be valid" do
    assert @program.valid?
  end

  #----------------------------------------------------------------------------#
  # message_streams:
  #-----------------
  test "can associate multiple message streams with a program" do
    assert_difference('@program.message_streams.size', 2) do
      2.times do
        stream = Factory.build(:message_stream, :program => @program)
        @program.message_streams << stream
      end
    end
  end

  #----------------------------------------------------------------------------#
  # name:
  #------
  test "should be invalid without a name" do
    @program.name = nil
    assert @program.invalid?
    assert @program.errors[:name].any?
  end

  test "cannot have two programs with the same name" do
    Factory.create(:program, :name => 'myprogram')
    @program.name = 'myprogram'
    assert @program.invalid?
    assert @program.errors[:name].any?
  end

  #----------------------------------------------------------------------------#
  # scopes:
  #--------
  test "should be sorted by name in ascending order" do
    ['w','b','e','x','n'].each do |name|
      Factory.create(:program, :name => name)
    end
    assert_equal Program.all.map(&:name).sort, Program.all.map(&:name)
  end

  #----------------------------------------------------------------------------#
  # title:
  #-------
  test "should be invalid without a title" do
    @program.title = nil
    assert @program.invalid?
    assert @program.errors[:title].any?
  end

end
