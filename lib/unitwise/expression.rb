require 'parslet'

require 'unitwise/expression/matcher'
require 'unitwise/expression/parser'
require 'unitwise/expression/transformer'
require 'unitwise/expression/composer'
require 'unitwise/expression/decomposer'

module Unitwise
  # The Expression module encompases all functions around encoding and decoding
  # strings into Measurement::Units and vice-versa.
  module Expression
    class << self
      # Build a string representation of a collection of terms
      # @param terms [Array]
      # @return [String]
      # @example
      #   Unitwise::Expression.compose(terms) # => "m2/s2"
      # @api public
      def compose(terms)
        Composer.new(terms).expression
      end

      # Convert a string representation of a unit, and turn it into a
      # an array of terms
      # @param expression [String] The string you wish to convert
      # @return [Array]
      # @example
      #   Unitwise::Expression.decompose("m2/s2") 
      #   # => [<Unitwise::Term m2>, <Unitwise::Term s-2>]
      # @api public
      def decompose(expression)
        expression = expression.to_s
        @decompose ||= {}
        if @decompose.has_key?(expression)
          @decompose[expression]
        else
          @decompose[expression] = begin
            Decomposer.new(expression).terms
          rescue ExpressionError
            nil
          end
        end
      end
    end
  end
end