module BoolTypecasting
  refine String do
    def to_bool
      return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
      return false if self == false || self.empty? || self =~ (/^(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
    end
    #  if using Rails empty? can be changed for blank?
  end

  if RUBY_VERSION >= "2.4"
    integer_class = Object.const_get("Integer")
  else
    integer_class = Object.const_get("Fixnum")
  end

  refine integer_class do
    def to_bool
      return true if self == 1
      return false if self == 0
      raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
    end
  end

  refine TrueClass do
    def to_i; 1; end
    def to_bool; self; end
  end

  refine FalseClass do
    def to_i; 0; end
    def to_bool; self; end
  end

  refine NilClass do
    def to_bool; false; end
  end
end
