
module Risc
  module Position

    # Listeners localise the changes that need to happen.
    #
    # An object listener assmes it is set up to the previous object.
    # so when position changes, it places itself just behind the previous object
    #
    # This is handy, since the "normal" chaining of object is forward
    # But the dependencies are backwards. This way we don't clutter the
    # actual object (or even the position), but keep the logic seperate.
    class ObjectListener

      # initialize with the object that needs to react to change
      def initialize(object)
        @object = object
      end

      # when the argument changes position, we update the objects
      # position to reflect that change
      #
      def position_changed(previous)
        me = previous.at + previous.object.padded_length
        object_pos = Position.get(@object)
        return if me == object_pos.at
        Position.set(@object , me)
      end
    end
  end
end