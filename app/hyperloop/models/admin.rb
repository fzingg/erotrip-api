require_relative 'application_record'
require_relative 'user'
class Admin < User
	default_scope -> { where(is_admin: true) }
 # Dummy
end