class Api::UsersController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :set_user, only: [:update, :update_shop]
  before_action :authorize_user, only: [:update, :update_shop]

  def update
    if @user.id != params[:id].to_i
      return render json: { error: "User not found." }, status: :not_found
    end

    if params[:username] && params[:username].length > 50
      return render json: { error: "Username cannot exceed 50 characters." }, status: :bad_request
    end

    if params[:email] && !params[:email].match?(URI::MailTo::EMAIL_REGEXP)
      return render json: { error: "Invalid email format." }, status: :bad_request
    end

    update_service = UserService::Update.new(@user.id, params[:email], params[:username], nil)
    result = update_service.call

    if result[:error]
      render json: { error: result[:error] }, status: :conflict
    else
      render json: {
        status: 200,
        message: "Profile updated successfully.",
        user: {
          id: @user.id,
          username: params[:username] || @user.username,
          email: params[:email] || @user.email,
          updated_at: @user.updated_at.iso8601
        }
      }, status: :ok
    end
  end

  def update_shop
    shop_service = ShopService::Update.new(
      user: @user,
      shop_id: params[:id],
      name: params[:shop_name],
      address: params[:shop_description]
    )

    begin
      shop_service.call
      render json: {
        status: 200,
        message: "Shop information updated successfully.",
        shop: {
          user_id: @user.id,
          shop_name: params[:shop_name],
          shop_description: params[:shop_description],
          updated_at: Time.now.utc.iso8601
        }
      }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    render json: { error: "User not found." }, status: :not_found unless @user
  end

  def authorize_user
    if action_name == 'update'
      authorize @user, policy_class: ApplicationPolicy
    elsif action_name == 'update_shop'
      authorize @user, policy_class: ShopPolicy
    end
  end
end
