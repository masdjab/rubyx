# A factory has the one job of handing out new instances
#
# A factory is for a specific type (currently, may change by size at some point)
#
# get_next_object is the main entry point, all other functions help to get more
# memory and objects as needed
#
# A factory keeps a reserve, and in case the freelist is empty, switches that in _immediately
# This is especially useful for messages, that can then be used even they run out.
#
# The idea (especially for messages) is to call out from the MessageSetup to the
# factory when the next (not current) is nil.
# This is btw just as easy a check, as the next needs to be gotten to swap the list.

module Parfait
  class Factory < Object
    attr_reader :for_type , :next_object , :reserve , :attribute_name , :page_size
    def self.type_length
      6
    end
    def self.memory_size
      8
    end

    # initialize for a given type (for_type). The attribute that is used to create the
    # list is the first that starts with next_ . "next" itself would have been nice and general
    # but is a keyword, so no go.
    def initialize(type , page)
      @for_type = type
      @attribute_name = type.names.find {|name| name.to_s.start_with?("next")}
      @page_size = page
      raise "No next found for #{type.class_name}" unless @attribute_name
    end

    # get the next free object, advancing the list.
    # Calls out to get_more if the list is empty.
    # This function is not realy used, as it is hard-coded in risc, but the get_more is
    # used, as it get's called from risc (or will)
    def get_next_object
      unless( @next_object )
        @next_object = reserve
        get_more
      end
      get_head
    end

    # this gets the head of the freelist, swaps it out agains the next and returns it
    def get_head
      nekst = @next_object
      @next_object = get_next_for(nekst)
      return nekst
    end

    # get more from system
    # and rebuilt the reserve (get_next already instantiates the reserve)
    #
    def get_more
      @reserve = get_chain
      last_link = @reserve
      count = @page_size / 100
      count = 15 if count < 15
      while(count > 0)
        last_link = get_next_for(last_link)
        count -= 1
      end
      @next_object = get_next_for(last_link)
      set_next_for( last_link , nil )
      self
    end

    # this initiates the syscall to get more memory.
    # it creates objects from the mem and link them into a chain
    def get_chain
      raise "type is nil" unless @for_type
      first = sys_mem( for_type , @page_size)
      chain = first
      counter = @page_size
      while( counter > 0)
        nekst = get_next_raw( chain )
        set_next_for(chain,  nekst)
        chain = nekst
        counter -= 1
      end
      first
    end

    # get the next_* attribute from the given object.
    # the attribute name is determined in initialize
    def get_next_for(object)
      object.send(attribute_name)
    end

    # set the next_* attribute of the given object, with the value.
    # the attribute name is determined in initialize
    def set_next_for(object , value)
      object.send("_set_#{attribute_name}".to_sym , value)
    end

    # Return the object _after the given one. In memory terms the next object starts
    # after the object ends. So this is in fact pointer arithmetic (once done)
    # This implementation will be moved to the adapter, as the real thing needs to be coded
    # in risc
    # This adapter version just return a new object
    def get_next_raw( object )
      sys_mem( object.get_type , 1)
    end

    # return more memory from the system.
    # Or to be more precise (as that is not really possible), allocate memory
    # for Factory.page_size objects, and return the first object.
    # ( the object has a type as first member, that type will be the for_type of this factory)
    # This implementation will be moved to the adapter, as the real thing needs to be coded
    # in risc
    # This adapter version just return a new object (by establishing the ruby class
    # and using ruby's allocate and set_type)
    def sys_mem( type , amount)
      r_class = eval( "Parfait::#{type.object_class.name}" )
      obj = r_class.allocate
      obj.set_type(type)
      obj
    end
  end
end
