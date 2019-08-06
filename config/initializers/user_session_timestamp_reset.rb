#Rails.logger.warn "\n\n\n\n IN USER SESSION INITIALIZER -- #{defined? Rails::Server} --- #{Hyperloop.on_server?} \n\n\n"
# if Hyperloop.on_server?
#     user_model = begin
#       Object.const_get 'User'
#     rescue LoadError
#     rescue NameError => e
# 		puts "Model `User` does not exist, hence will not reset session timestamps"
#     end

# 	if user_model
# 		if (missing_columns = ['active_since', 'inactive_since'] - User.column_names).empty?
# 			result = User.update_all(active_since: nil)
# 			puts "Updated all User records with `active_since: nil` -> #{result}"
# 		else
# 			puts "`User` table does not have columns: #{missing_columns.join(', ')}. ...add them :)"
# 		end
# 	end
# end