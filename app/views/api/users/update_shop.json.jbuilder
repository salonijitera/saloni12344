json.status 200
json.message "Shop information updated successfully."
json.shop do
  json.user_id @user.id
  json.shop_name @shop.shop_name
  json.shop_description @shop.shop_description
  json.updated_at @shop.updated_at.iso8601
end
