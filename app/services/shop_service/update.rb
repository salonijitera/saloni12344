# frozen_string_literal: true

module ShopService
  class Update < BaseService
    attr_reader :user, :shop_id, :name, :address

    def initialize(user:, shop_id:, name:, address:)
      @user = user
      @shop_id = shop_id
      @name = name
      @address = address
    end

    def call
      authorize_user!
      validate_presence!
      shop = find_shop!
      shop.update!(name: name, address: address)
      { message: 'Shop information has been updated successfully.' }
    end

    private

    def authorize_user!
      raise 'User not authorized to update shop information' unless ApplicationPolicy.new(user, Shop).update?
    end

    def validate_presence!
      raise 'Name and address cannot be blank' if name.blank? || address.blank?
    end

    def find_shop!
      Shop.find(shop_id)
    end
  end
end
