def consolidate_cart(cart)
  cart.reduce({}) do |memo, item|
    name = item.keys[0]
    memo.keys.include?(name) ? memo[name][:count] += 1 : memo[name] = item.values[0].merge({:count=>1})
    memo
  end
end

def apply_coupons(cart, coupons)
  coupons.each do |coup|
    current = cart[coup[:item]]
    if current
      if current[:count] >= coup[:num]
        if cart["#{coup[:item]} W/COUPON"]
          cart["#{coup[:item]} W/COUPON"][:count] += coup[:num]
        else
          cart["#{coup[:item]} W/COUPON"] = {:price => coup[:cost] / coup[:num], :clearance => current[:clearance], :count => coup[:num]}
        end
        current[:count] -= coup[:num]
      end
    end
  end
  cart
end

def apply_clearance(cart)
  cart.reduce({}) do |memo, (k, v)|
    v[:price] = (v[:price] * 0.8).round(2) if v[:clearance]
    memo.merge({k => v})
  end
end

def checkout(cart, coupons)
  updated = apply_clearance(apply_coupons(consolidate_cart(cart), coupons))
  total = updated.reduce(0) {|memo, (_k, v)| memo + v[:price] * v[:count]}
  total > 100 ? total *= 0.9 : total
end
