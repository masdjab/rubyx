module SlotMachine

  # Transering the arguments from the current frame into the next frame
  #
  # This could be _done_ at this level, and in fact used to be.
  # The instruction was introduced to
  # 1. make optimisations easier
  # 2. localise the inevitable change
  #
  # 1. The optimal risc implementation for this loads old and new frames into registers
  #    and does a whole bunch of transfers
  #    But if we do individual SlotMoves here, each one has to load the frames,
  #    thus making advanced analysis/optimisation neccessary to achieve the same effect.
  #
  # 2. Closures will have to have access to variables after the frame goes out of scope
  #    and in fact be able to change the parents variables. The current design does not allow
  #    for this, and so will have to be change in the not so distant future.
  #
  class ArgumentTransfer < Instruction

    attr_reader :receiver , :arguments

    # receiver is a slot_definition
    # arguments is an array of SlotLoads
    def initialize( source , receiver,arguments )
      super(source)
      @receiver , @arguments = receiver , arguments
      raise "Receiver not SlotDefinition #{@receiver}" unless @receiver.is_a?(SlotDefinition)
      @arguments.each{|a| raise "args not SlotLoad #{a}" unless a.is_a?(SlotLoad)}
    end

    def to_s
      "ArgumentTransfer " + ([@receiver] + @arguments).join(",")
    end

    # load receiver and then each arg into the new message
    # delegates to SlotLoad for receiver and to the actual args.to_risc
    def to_risc(compiler)
      transfer = SlotLoad.new(self.source ,[:message , :next_message , :receiver] , @receiver, self).to_risc(compiler)
      #TODO transfer the Number of arguments to :arguments_given (to be checked on entry)
      compiler.reset_regs
      @arguments.each do |arg|
        arg.to_risc(compiler)
        compiler.reset_regs
      end
      transfer
    end
  end


end
