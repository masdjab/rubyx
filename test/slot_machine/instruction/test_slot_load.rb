require_relative "helper"

module SlotMachine
  class TestSlotLoadBasics < MiniTest::Test

    def test_ins_ok
      assert SlotLoad.new("test", [:message, :caller] , [:receiver,:type] )
    end
    def test_ins_fail1
      assert_raises {SlotLoad.new( "test",[:message, :caller] , nil )}
    end
    def test_fail_on_right
      @load = SlotLoad.new( "test",[:message, :caller] , [:receiver,:type] )
      assert_raises {@load.to_risc(Risc::FakeCompiler.new)}
    end
    def test_fail_on_left_long
      @load = SlotLoad.new("test", [:message, :caller , :type] , [:receiver,:type] )
      assert_raises {@load.to_risc(Risc::FakeCompiler.new)}
    end
  end
end
