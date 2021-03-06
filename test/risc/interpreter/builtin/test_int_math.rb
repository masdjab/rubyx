require_relative "../helper"

module Risc
  module Macro
    class IntMath < Minitest::Test
      include Ticker
      def setup
      end

      def test_add
        @preload = "Integer.plus"
        run_main_return "5 + 5"
        assert_equal 10 , get_return
      end
      def test_minus
        @preload = "Integer.minus"
        run_main_return "5 - 5"
        assert_equal 0 , get_return
      end
      def test_minus_neg
        @preload = "Integer.minus"
        run_main_return "5 - 15"
        assert_equal( -10 , get_return)
      end
      def test_rshift
        @preload = "Integer.rs"
        run_main_return "#{2**8} >> 3"
        assert_equal 2**5 , get_return
      end
      def test_lshift
        @preload = "Integer.ls"
        run_main_return "#{2**8} << 3"
        assert_equal 2**11 , get_return
      end
      def test_div10
        @preload = "Integer.div10"
        run_main_return "45.div10"
        assert_equal 4 , get_return
      end
      def test_div4
        @preload = "Integer.div4"
        run_main_return "45.div4"
        assert_equal 11 , get_return
      end
      def test_mult
        @preload = "Integer.mul"
        run_main_return "4 * 4"
        assert_equal 16 , get_return
      end
    end
  end
end
