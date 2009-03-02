class Module #:nodoc:
  def dsl_accessor(*symbols)
    symbols.each do |sym|
      class_eval %{
        def #{sym}(*val)
          if val.empty?
            @#{sym}
          else
            @#{sym} = val.size == 1 ? val[0] : val
          end
        end
      }, __FILE__, __LINE__
    end
  end
end
