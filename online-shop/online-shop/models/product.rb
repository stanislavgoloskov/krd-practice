class Product
    attr_reader :id, :name, :price, :image, :description
    
    def initialize(id, name, price, image, description)
      @id = id
      @name = name
      @price = price
      @image = image
      @description = description
    end
  end