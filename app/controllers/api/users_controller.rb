module Api
  class UsersController < ApplicationController
    before_action :doorkeeper_authorize!, except: [:register]
    before_action :set_user, only: [:update]

    def register
      result = UserService.register(
        username: user_params[:username],
        email: user_params[:email],
        password: user_params[:password],
        password_confirmation: user_params[:password] # Assuming password confirmation is the same as password for simplicity
      )

      if result[:error].present?
        render json: { message: result[:error] }, status: :bad_request
      else
        user = User.find_by(username: user_params[:username])
        render json: {
          status: 201,
          message: result[:message],
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            created_at: user.created_at.iso8601
          }
        }, status: :created
      end
    rescue ArgumentError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

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

    private

    def user_params
      params.permit(:username, :email, :password)
    end

    def set_user
      @user = User.find_by(id: params[:id])
      render json: { error: "User not found." }, status: :not_found unless @user
    end
  end
end
