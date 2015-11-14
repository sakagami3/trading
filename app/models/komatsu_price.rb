class KomatsuPrice < ActiveRecord::Base
  def self.price_to_f(price)
    price = price.gsub(',', '').to_f

    unless price >= 0.0
      raise '値が正しくありません。'
    end

    price
  end
end
