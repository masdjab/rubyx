module Bosl
  Compiler.class_eval do
#    module attr_reader  :name ,:expressions
    def on_module expression
      name , rest = *expression
      return process_all(rest).last
    end

    def on_class expression
      #puts expression.inspect
      name , derives , expressions = *expression
      clazz = Parfait::Space.object_space.get_class_by_name! name
      #puts "Compiling class #{clazz.name.inspect}"
      expression_value = process_all(expressions).last

      return expression_value
    end
  end
end