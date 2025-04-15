class Cart
    attr_reader :items
    
    def initialize
      @items = []
    end
    
    def add_item(product, quantity = 1)
      item = @items.find { |i| i[:product].id == product.id }
      
      if item
        item[:quantity] += quantity
      else
        @items << { product: product, quantity: quantity }
      end
    end
    
    def total
      @items.sum { |item| item[:product].price * item[:quantity] }
    end
  end