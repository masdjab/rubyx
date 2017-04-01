require_relative "collector"

module Risc
  # The Risc Machine is an abstraction of the register level. This is seperate from the
  # actual assembler level to allow for several cpu architectures.
  # The Instructions (see class Instruction) define what the machine can do (ie load/store/maths)

  # The ast is transformed to virtual-machine objects, some of which represent code, some data.
  #
  # The next step transforms to the register machine layer, which is quite close to what actually
  #  executes. The step after transforms to Arm, which creates executables.
  #

  class Machine
    include Collector
    include Logging
    log_level :info

    def initialize
      @booted = false
      @constants = []
    end
    attr_reader  :constants , :init  , :booted

    # idea being that later method missing could catch translate_xxx and translate to target xxx
    # now we just instantiate ArmTranslater and pass instructions
    def translate_arm
      methods = Parfait.object_space.collect_methods
      translate_methods( methods )
      label = @init.next
      @init = Arm::Translator.new.translate( @init )
      @init.append label
    end

    def translate_methods(methods)
      translator = Arm::Translator.new
      methods.each do |method|
        log.debug "Translate method #{method.name}"
        instruction = method.instructions
        while instruction.next
          nekst = instruction.next
          t = translator.translate(nekst) # returning nil means no replace
          if t
            nekst = t.last
            instruction.replace_next(t)
          end
          instruction = nekst
        end
      end
    end

    def boot
      initialize
      boot_parfait!
      @init =  Branch.new( "__initial_branch__" , Parfait.object_space.get_init.instructions )
      @booted = true
      self
    end

  end

  # Module function to retrieve singleton
  def self.machine
    unless defined?(@machine)
      @machine = Machine.new
    end
    @machine
  end

end

Parfait::TypedMethod.class_eval do
  # for testing we need to reuse the main function (or do we?)
  # so remove the code that is there
  def clear_source
    self.source.send :initialize , self
  end

end

require_relative "boot"