require 'signed_multiset'
module Unitwise
  class Term
    attr_writer :atom_code, :prefix_code, :atom, :prefix
    attr_writer :factor, :exponent
    attr_accessor :annotation

    include Unitwise::Composable

    def initialize(attributes)
      attributes.each do |k,v|
        public_send :"#{k}=", v
      end
    end

    def prefix_code
      @prefix_code ||= (@prefix.primary_code if @prefix)
    end

    def prefix
      @prefix ||= (Prefix.find(@prefix_code) if @prefix_code)
    end

    def atom_code
      @atom_code ||= (@atom.primary_code if @atom)
    end

    def atom
      @atom ||= (Atom.find(@atom_code) if @atom_code)
    end

    def depth
      atom ? atom.depth + 1 : 0
    end

    def terminal?
      depth <= 3
    end

    def factor
      @factor ||= 1
    end

    def exponent
      @exponent ||= 1
    end

    def scale
      (factor * (prefix ? prefix.scale : 1) * (atom ? atom.scale : 1)) ** exponent
    end

    def root_terms
      if terminal?
        [self]
      else
        atom.measurement.root_terms.map do |t|
          Term.new(atom: t.atom, exponent: t.exponent * exponent)
        end
      end
    end

    def to_hash
      [:prefix, :atom, :exponent, :factor, :annotation].inject({}) do |h, a|
        h[a] = send a; h
      end
    end

    def **(integer)
      Term.new(to_hash.merge(exponent: exponent * integer))
    end

    def to_s
      [(factor if factor != 1), prefix_code,
        atom_code, (exponent if exponent != 1)].compact.join('')
    end

    def inspect
      "<#{self.class} #{to_s}>"
    end

  end
end