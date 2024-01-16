require 'user_service'
class Api::UsersController < ApplicationController
  before_action :doorkeeper_authorize!, except: [:verify_email]
  before_action :set_user, only: [:update, :update_shop, :verify_email]
  before_action :authorize_user, only: [:update, :update_shop]

  # POST /api/users/verify-email
  def verify_email
    token = params[:token]
    return render json: { error: "Token is required." }, status: :bad_request if token.blank?

    result = UserService::VerifyEmail.new(token).call

    if result[:message]
      render json: { status: 200, message: result[:message] }, status: :ok
    elsif result[:error]
      case result[:error]
      when 'Invalid or expired token.'
        render json: { error: result[:error] }, status: :not_found
      else
        render json: { error: result[:error] }, status: :internal_server_error
      end
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

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
