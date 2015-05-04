module Compiler
#    module attr_reader  :name ,:expressions
    def compile_module expression , context
      return clazz
    end

    def compile_class expression , method , message
      clazz = ::Virtual::BootSpace.space.get_or_create_class name
      puts "Created class #{clazz.name.inspect}"
      expression.expressions.each do |expr|
        # check if it's a function definition and add
        # if not, execute it, but that does means we should be in salama (executable), not ruby. ie throw an error for now
        raise "only functions for now #{expr.inspect}" unless expr.is_a? Ast::FunctionExpression
        #puts "compiling expression #{expression}"
        expression_value = expr.compile(method,message )
        clazz.add_instance_method(expression_value)
        #puts "compiled expression #{expression_value.inspect}"
      end

      return clazz
    end
end