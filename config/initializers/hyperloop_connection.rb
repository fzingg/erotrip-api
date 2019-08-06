module Hyperloop
	class Connection < ActiveRecord::Base
		unless RUBY_ENGINE == 'opal'

			after_create 	:log_active_since_on_user, 		if: :user_specific_channel?
			after_destroy 	:log_inactive_since_on_user, 	if: :user_specific_channel?

			def user_specific_channel?
				channel =~ /User-[0-9]+/
			end

			def user
				channel =~ /User-([0-9]+)/ ? @user ||= User.find_by_id($1) : nil
			end

			def log_active_since_on_user
				puts "!!! WILL log_active_since_on_user, #{user.try(:id)}"
				user.try(:update_attributes, { active_since: Time.now, inactive_since: nil })
			end

			def log_inactive_since_on_user
				puts "!!! WILL log_inactive_since_on_user, #{user.try(:id)}"
				user.try(:update_attributes, { active_since: nil, inactive_since: Time.now })
			end

		end
	end
end