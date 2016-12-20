require_relative "helper"

module Melon
  class TestMethodCollector < MiniTest::Test

    def setup
      Register.machine.boot unless Register.machine.booted
    end

    def parse_collect( input )
      ast = Parser::Ruby22.parse input
      MethodCollector.new.collect(ast)
    end

    def test_no_args
      methods = parse_collect "def meth; @ivar;end"
      assert methods.find{|m| m.name == :meth }
    end

    def test_one_arg
      method = parse_collect("def meth2(arg1); 1;end").first
      assert method.name == :meth2
      assert method.args_type.variable_index(:arg1) , method.args_type.inspect
    end

    def test_ivar_operator_assign
      method = parse_collect("def meth3(yksi,kaksi,kolme); 1;end").first
      assert method.args_type.variable_index(:kolme) , method.args_type.inspect
    end

  end
end
