require_relative 'helper'

module Register
  class TestReturnStatement < MiniTest::Test
    include Statements

    def test_return_int
      @input = s(:statements, s(:return, s(:int, 5)))
      @expect =   [Label, LoadConstant, RegToSlot, LoadConstant, SlotToReg, RegToSlot ,
                 Label, FunctionReturn]
      assert_nil msg = check_nil , msg
    end

    def test_return_local
      Parfait.object_space.get_main.add_local(:runner , :Integer)
      @input = s(:statements, s(:return, s(:name, :runner)))
      @expect =  [Label, SlotToReg, SlotToReg, RegToSlot, LoadConstant, SlotToReg ,
                 RegToSlot, Label, FunctionReturn]
      assert_nil msg = check_nil , msg
    end

    def test_return_local_assign
      Parfait.object_space.get_main.add_local(:runner , :Integer)
      @input = s(:statements, s(:assignment, s(:name, :runner), s(:int, 5)), s(:return, s(:name, :runner)))
      @expect =  [Label, LoadConstant, SlotToReg, RegToSlot, SlotToReg, SlotToReg ,
                 RegToSlot, LoadConstant, SlotToReg, RegToSlot, Label, FunctionReturn]
      assert_nil msg = check_nil , msg
    end

    def test_return_call
      @input =s(:statements, s(:return, s(:call, s(:name, :main), s(:arguments))))
      @expect =  [Label, SlotToReg, SlotToReg, RegToSlot, LoadConstant, RegToSlot ,
                 LoadConstant, SlotToReg, RegToSlot, LoadConstant, RegToSlot, RegisterTransfer ,
                 FunctionCall, Label, RegisterTransfer, SlotToReg, SlotToReg, RegToSlot ,
                 LoadConstant, SlotToReg, RegToSlot, Label, FunctionReturn]
      assert_nil msg = check_nil , msg
    end

    def pest_return_space_length # need to add runtime first
      Parfait.object_space.get_main.add_local(:l , :Type)
      @input = s(:statements, s(:assignment, s(:name, :l), s(:call, s(:name, :get_type), s(:arguments), s(:receiver, s(:name, :space)))), s(:return, s(:field_access, s(:receiver, s(:name, :self)), s(:field, s(:name, :runner)))))
      @expect =  [Label, SlotToReg,SlotToReg ,RegToSlot,Label,FunctionReturn]
      assert_nil msg = check_nil , msg
    end

  end
end