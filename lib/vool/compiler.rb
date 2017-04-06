module Vool
  class Compiler < AST::Processor

    def self.compile(input)
      ast = Parser::Ruby22.parse( input )
      self.new.process(ast)
    end

    # default to error, so non implemented stuff shows early
    def handler_missing(node)
      raise "Not implemented #{node.type} #{node}"
    end

    def on_class( statement )
      name , sup , body = *statement
      ClassStatement.new( get_name(name) , get_name(sup) , process_all(body) )
    end

    def on_def( statement )
      name , args , body = *statement
      arg_array = process_all( args )
      MethodStatement.new( name , arg_array , process(body) )
    end

    def on_arg( arg )
      arg.first
    end

    #basic Values
    def on_self exp
      SelfStatement.new
    end

    def on_nil expression
      NilStatement.new
    end

    def on_int expression
      IntegerStatement.new(expression.children.first)
    end

    def on_float expression
      FloatStatement.new(expression.children.first)
    end

    def on_true expression
      TrueStatement.new
    end

    def on_false expression
      FalseStatement.new
    end

    def on_str expression
      StringStatement.new(expression.children.first)
    end
    alias  :on_string :on_str

    def on_dstr expression
      raise "Not implemented dynamic strings (with interpolation)"
    end
    alias  :on_xstr :on_dstr

    def on_sym expression
      SymbolStatement.new(expression.children.first)
    end
    alias  :on_string :on_str

    def on_dsym
      raise "Not implemented dynamix symbols (with interpolation)"
    end
    def on_kwbegin statement
      ScopeStatement.new process_all( statement.children )
    end
    alias  :on_begin :on_kwbegin

    # Array + Hashes
    def on_array expression
      ArrayStatement.new expression.children.collect{ |elem| process(elem) }
    end

    def on_hash expression
      hash = HashStatement.new
      expression.children.each do |elem|
        raise "Hash error, hash contains non pair: #{elem.type}" if elem.type != :pair
        hash.add( process(elem.children[0]) , process(elem.children[1]) )
      end
      hash
    end

    #Variables
    def on_lvar expression
      LocalVariable.new(expression.children.first)
    end

    def on_ivar expression
      InstanceVariable.new(instance_name(expression.children.first))
    end

    def on_cvar expression
      ClassVariable.new(expression.children.first.to_s[2 .. -1].to_sym)
    end

    def on_const expression
      scope = expression.children.first
      if scope
        raise "Only unscoped Names implemented #{scope}" unless scope.type == :cbase
      end
      ModuleName.new(expression.children[1])
    end

    # Assignements
    def on_lvasgn expression
      name = expression.children[0]
      value = process(expression.children[1])
      LocalAssignment.new(name,value)
    end

    def on_ivasgn expression
      name = expression.children[0]
      value = process(expression.children[1])
      InstanceAssignment.new(instance_name(name),value)
    end

    def on_return statement
      return_value = process(statement.children.first)
      ReturnStatement.new( return_value )
    end

    def on_while statement
      condition , statements = *statement
      w = WhileStatement.new( process(condition) )
      simplify_condition(w)
      w.statements = process(statements)
      w
    end

    def on_if statement
      condition , if_true , if_false = *statement
      w = IfStatement.new( process(condition) )
      simplify_condition(w)
      w.if_true = process(if_true)
      w.if_false = process(if_false)
      w
    end

    def on_send statement
      kids = statement.children.dup
      receiver = kids.shift
      name = kids.shift
      arguments = kids
      w = SendStatement.new( name )
      w.receiver = process(receiver) || SelfStatement.new
      w.arguments = process_all(arguments)
      w
    end

    def on_and expression
      name = expression.type
      left = process(expression.children[0])
      right = process( expression.children[1] )
      LogicalStatement.new( name , left , right)
    end
    alias :on_or :on_and

    # this is a call to super without args (z = zero arity)
    def on_zsuper exp
      w = SendStatement.new( nil )
      w.receiver = SuperStatement.new
      w
    end

    # this is a call to super with args and
    # same name as current method, which is set later
    def on_super( statement )
      w = SendStatement.new( nil )
      w.receiver = SuperStatement.new
      w.arguments = process_all(statement.children)
      w
    end

    def on_assignment statement
      name , value = *statement
      w = Assignment.new()
      w.name = process name
      w.value = process(value)
      w
    end

    private

    def simplify_condition( cond )
      condition = cond.condition
      return unless condition.is_a?(ScopeStatement)
      cond.condition = condition.first if condition.single?
    end

    def instance_name sym
      sym.to_s[1 .. -1].to_sym
    end

    def get_name( statement )
      return nil unless statement
      raise "Not const #{statement}" unless statement.type == :const
      name = statement.children[1]
      raise "Not symbol #{name}" unless name.is_a? Symbol
      name
    end

  end
end
