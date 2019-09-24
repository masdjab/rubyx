#
# In many respects a SingletonClass is like a Class. We haven't gone to the full ruby/oo level
# yet, where the singleton_class is actually a class instance, but someday.

# A Class in general can be viewed as a way to generate methods for a group of objects.

# A SingletonClass serves the same function, but just for one object, the class object that it
# is the singleton_class of.
# This is slightly different in the way that the type of the class must actually
# change, whereas for a class the instance type changes and only objects generated
# henceafter have a different type.

# Another current difference is that a singleton_class has no superclass. Also no name.
# There is a one to one relationship between a class instance and it's singleton_class instance.

module Parfait
  class SingletonClass < Behaviour

    attr_reader :clazz

    def self.type_length
      4
    end
    def self.memory_size
      8
    end

    def initialize( clazz , clazz_type)
      raise "No type for #{clazz.name}" unless clazz_type
      super( clazz_type )
      @clazz = clazz
    end

    def rxf_reference_name
      @clazz.name
    end

    def inspect
      "SingletonClass(#{@clazz.name})"
    end

    def to_s
      inspect
    end

    # adding an instance changes the instance_type to include that variable
    def add_instance_variable( name , type)
      super(name,type)
      @clazz.set_type(@instance_type)
    end

    # Nil name means no superclass, and so nil returned
    def super_class
      return nil
    end

    # no superclass, return nil to signal
    def super_class_name
      nil
    end

  end
end