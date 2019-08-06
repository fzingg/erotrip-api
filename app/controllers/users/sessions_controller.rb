# class Users::SessionsController < Devise::SessionsController
#   # before_action :x, only: [:create]

#   # GET /resource/sign_in
#   # def new
#   #   super
#   # end

#   # POST /resource/sign_in
#   # def create
#   #   super
#   # end
#   def create
#     return invalid_login_attempt if params[:user].blank?
#     resource = User.find_for_database_authentication(email: params[:user][:email])
#     return invalid_login_attempt unless resource

#     if resource.valid_password?(params[:user][:password])
#       sign_in :user, resource
#       render json: { user: resource } and return
#     end

#     invalid_login_attempt
#    end

#   # DELETE /resource/sign_out
#   # def destroy
#   #   super
#   # end

#   protected

#     def invalid_login_attempt
#       set_flash_message(:alert, :invalid)
#       render json: { errors: { base: flash[:alert] } }.to_json, status: 401
#     end

#     # If you have extra params to permit, append them to the sanitizer.
#     # def configure_sign_in_params
#     #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
#     # end

#     def respond_to_on_destroy
#       # We actually need to hardcode this as Rails default responder doesn't
#       # support returning empty response on GET request
#       respond_to do |format|
#         format.all { head :no_content }
#         format.html { redirect_to after_sign_out_path_for(resource_name) }
#         format.json { render json: { base: 'Signed_out' } }.to_json
#       end
#     end

#     def require_no_authentication
#       assert_is_devise_resource!
#       return unless is_navigational_format?
#       no_input = devise_mapping.no_input_strategies

#       authenticated = if no_input.present?
#         args = no_input.dup.push scope: resource_name
#         warden.authenticate?(*args)
#       else
#         warden.authenticated?(resource_name)
#       end

#       if authenticated && resource = warden.user(resource_name)
#         flash[:alert] = I18n.t("devise.failure.already_authenticated")
#         if request.format.html?
#           redirect_to after_sign_in_path_for(resource)
#         else
#           render json: { errors: { base: 'Jesteś już zalogowany' }, id: current_user.id }.to_json, status: 401
#         end
#       end
#     end
# end
