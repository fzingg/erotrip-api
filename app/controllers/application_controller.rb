class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user_id_in_thread

  def home
  end

  def set_current_user_id_in_thread
    Thread.current[:current_user_id] = current_user.try(:id)
  end

  def acting_user
    current_user
  end

  def landing_page
    render action: 'landing_page', layout: 'landing_page_layout'
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :kind,
        :name,
        :birth_year,
        :name_second_person,
        :birth_year_second_person,
        :city,
        :lon,
        :lat,
        :email,
        :password,
        :password_confirmation,
        :pin,
        :pin_confirmation,
        :terms_acceptation
      ])
    end

end
