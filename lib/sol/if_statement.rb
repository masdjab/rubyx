
module Sol
  class IfStatement < Statement

    attr_reader :condition , :if_true , :if_false

    def initialize( cond , if_true , if_false = nil)
      @condition = cond
      @if_true = if_true
      @if_false = if_false
    end

    def to_slot( compiler )
      true_label  = SlotMachine::Label.new( self , "true_label_#{object_id.to_s(16)}")
      false_label = SlotMachine::Label.new( self , "false_label_#{object_id.to_s(16)}")
      merge_label = SlotMachine::Label.new( self , "merge_label_#{object_id.to_s(16)}")

      if @condition.is_a?(CallStatement)
        head = @condition.to_slot(compiler)
        head << check_slot(compiler , false_label)
      else
        head = check_slot(compiler , false_label)
      end
      head << true_label
      head << if_true.to_slot(compiler)   if @if_true
      head << SlotMachine::Jump.new(merge_label) if @if_false
      head << false_label
      head << if_false.to_slot(compiler)  if @if_false
      head << merge_label                if @if_false
      head
    end

    # create the slot lazily, so to_slot gets called first
    def check_slot(compiler , false_label)
      SlotMachine::TruthCheck.new(@condition.to_slot_definition(compiler) , false_label)
    end

    def each(&block)
      block.call(condition)
      @if_true.each(&block) if @if_true
      @if_false.each(&block) if @if_false
    end

    def has_false?
      @if_false != nil
    end

    def has_true?
      @if_true != nil
    end

    def to_s(depth = 0)
      parts =  "if (#{@condition.to_s(0)})\n"
      parts += "  #{@if_true}\n" if @if_true
      parts += "else\n" if(@if_false)
      parts += "  #{@if_false}\n" if(@if_false)
      parts += "end\n"
      at_depth(depth , parts )
    end
  end
end
