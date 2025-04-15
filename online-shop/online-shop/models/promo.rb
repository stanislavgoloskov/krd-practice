class Promo
    attr_reader :code, :discount
    
    def initialize(code, discount)
      @code = code
      @discount = discount
    end
    
    def valid?(input_code)
      @code == input_code
    end
  end