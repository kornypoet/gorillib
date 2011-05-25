# -*- coding: utf-8 -*-
require 'enumerator'
module Receiver
  #
  # Makes a Receiver thingie behave mostly like a hash.
  #
  # By default, the hashlike methods iterate over the receiver attributes:
  # instance #keys delegates to self.class.keys which calls
  # receiver_attr_names. If you want to filter our add to the keys list, you
  # can just override the class-level keys method (and call super, or not):
  #
  #     def self.keys
  #       super + [:firstname, :lastname] - [:fullname]
  #     end
  #
  # All methods are defined naturally on [], []= and has_key? -- if you enjoy
  #
  #
  # in addition to the below, by including Enumerable, this also adds
  #
  #    #all?, #any?, #chunk, #collect, #collect_concat, #count, #cycle, #detect,
  #    #drop, #drop_while, #each_cons, #each_entry, #each_slice,
  #    #each_with_index, #each_with_object, #entries, #find, #find_all,
  #    #find_index, #first, #flat_map, #grep, #group_by, #inject, #map, #max,
  #    #max_by, #min, #min_by, #minmax, #minmax_by, #none?, #one?, #partition,
  #    #reduce, #reverse_each, #slice_before, #sort, #sort_by, #take,
  #    #take_while, #zip
  #
  # As opposed to hash, does *not* define
  #
  #   default, default=, default_proc, default_proc=, shift
  #   length, size, empty?, flatten, replace, keep_if, key(value)
  #   compare_by_identity compare_by_identity? rehash, select!
  #
  #   assoc rassoc
  #
  module ActsAsHash

    # Fake hash reader semantics: delegates to self.send(key)
    #
    # Note: indifferent access -- either of :foo or "foo" will work
    #
    def [](name)
      self.send(name) if members.include?(name.to_sym)
    end

    # Fake hash writer semantics: delegates to self.send("key=", val)
    #
    # NOTE: this calls self.foo= 5, not self.receive_foo(5)
    # NOTE: indifferent access -- either of :foo or "foo" will work
    #
    def []=(name, val)
      self.send("#{name}=", val) if members.include?(name.to_sym)
    end
    alias_method(:store, :[]=)

    # @param key<Object> The key to remove
    #
    # @return [Object]
    #   returns the value of the given attribute, and sets its new value to nil.
    #   If there is a corresponding instance_variable, it is subsequently removed.
    def delete(key)
      val = self[key]
      self[key] = nil
      unset!(key)
      val
    end

    # delegates to the class method. Typically you'll want to override that one,
    # not the instance keys
    def keys
      # self.class.members.select{|k| attr_set?(k) }
      instance_variables.map{|s| s[1..-1].to_sym }
    end
  end
end


    module ClassMethods
      # By default, the hashlike methods iterate over the receiver attributes.
      # If you want to filter our add to the keys list, override this method
      #
      # @example
      #     def self.members
      #       super + [:firstname, :lastname] - [:fullname]
      #     end
      #
      def members
        receiver_attr_names
      end
    end

    def keys
      super & members
    end
