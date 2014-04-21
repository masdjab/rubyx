module Asm

  class Node
  end

  class InstructionNode < Node
    attr_accessor :opcode, :args
  end

  class ArgNode < Node
  end

  class ShiftNode < Node
    attr_accessor :type, :value, :argument
  end

  class MathNode < Node
    attr_accessor :left, :right, :op
    alias_method :argument, :left
    alias_method :argument=, :left=
  end

  class RegisterArgNode < ArgNode
    attr_accessor :name
    def initialize name
      @name = name
    end
  end

  #maybe not used at all as code_gen::instruction raises if used.
  # instead now using Arrays
  class RegisterListArgNode < ArgNode
    attr_accessor :registers
    def initialize regs
      @registers = regs.collect{ |sym , reg| (sym == :reg) ? reg :  "not a reg #{sym} , #{reg}" }
    end
  end

  class NumLiteralArgNode < ArgNode
    attr_accessor :value
    def initialize val
      @value = val
    end
  end

  class LabelRefArgNode < ArgNode
    attr_accessor :label, :label_object
    def initialize label , object = nil
      @label = label
      @label_object = object
    end
  end

  class ParseError < StandardError
    def initialize(message, s)
      super(message)
    end
  end
end
