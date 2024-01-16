class Api::UsersController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :set_user, only: [:update]

  def update
    authorize @user, policy_class: ApplicationPolicy

    if @user.id != params[:id].to_i
      return render json: { error: "User not found." }, status: :not_found
    end

    if params[:username] && params[:username].length > 50
      return render json: { error: "Username cannot exceed 50 characters." }, status: :bad_request
    end

    if params[:email] && !params[:email].match?(URI::MailTo::EMAIL_REGEXP)
      return render json: { error: "Invalid email format." }, status: :bad_request
    end

    update_service = UserService::Update.new(@user.id, params[:email], nil, nil)
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

  private

  def set_user
    @user = User.find_by(id: params[:id])
    render json: { error: "User not found." }, status: :not_found unless @user
  end
end
