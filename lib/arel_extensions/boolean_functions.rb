# coding: utf-8
require 'arel_extensions/nodes/then'

module ArelExtensions
  module BooleanFunctions

    def ⋀(other)
      self.and(other)
    end

    def and *others
      Arel::Nodes::And.new self, others
    end

    def ⋁(other)
      self.or(other)
    end

    def or *others
      Arel::Nodes::Or.new self, others
    end

    def then(t, f = nil)
      ArelExtensions::Nodes::Then.new [self, t, f]
    end

  end
end

class Arel::Nodes::And
  include ArelExtensions::BooleanFunctions

  def self.new *children
    children =
      children.flatten.map { |c|
      c.is_a?(self) ? c.children : c
    }.flatten
    super(children)
  end

end

# For some reason, Arel's And is properly defined as variadic (it
# stores @children, and hashes it all).  However Arel's Or is defined
# as binary, with only @left and @right, and hashing only @left and @right.
#
# So reimplement its ctor and accessors.

class Arel::Nodes::Or
  include ArelExtensions::BooleanFunctions

  attr_reader :children

  def self.new *children
    children =
      children.flatten.map { |c|
      c.is_a?(self) ? c.children : c
    }.flatten
    super(*children)
  end

  def initialize *children
    @children = children
  end

  def hash
    children.hash
  end

end
