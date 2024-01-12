class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user.present?
      PasswordMailer.with(user: @user).reset.deliver_now
    end

    redirect_to root_path, notice: "If an account with that email was found, we sent you an link to reset your password."
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: "password_reset")
  rescue
    redirect_to sign_in_path, alert: "Your token has expired. Please try again."
  end

  def update
    @user = User.find_signed(params[:token], purpose: "password_reset")
    @user.update!(password_params)

    redirect_to sign_in_path, notice: "Your token was reset successfully. Please sign in."
  rescue
    render :edit, status: :unprocessable_entity
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
