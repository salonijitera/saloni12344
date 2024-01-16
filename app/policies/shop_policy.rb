# frozen_string_literal: true

class ShopPolicy < ApplicationPolicy
  def update?
    # Assuming the user has an attribute `admin` that indicates if they are an admin
    # and `shop_id` to check if they own the shop.
    # This logic may vary depending on the application's requirements.
    user.admin? || record.id == user.shop_id
  end
end

