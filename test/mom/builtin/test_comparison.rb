require_relative "helper"

module Mom
  module Builtin
    class TestIntComp1Risc < BootTest
      def setup
        super
        @method = get_int_compiler(:<)
      end
      def test_compile
        assert_equal Risc::MethodCompiler , @method.to_risc.class
      end
      def test_risc_length
        assert_equal 27 , @method.to_risc.risc_instructions.length
      end
    end
    class TestIntComp2Risc < BootTest
      def setup
        super
        @method = get_int_compiler(:>=)
      end
      def test_compile
        assert_equal Risc::MethodCompiler , @method.to_risc.class
      end
      def test_risc_length
        assert_equal 26 , @method.to_risc.risc_instructions.length
      end
    end
  end
end
