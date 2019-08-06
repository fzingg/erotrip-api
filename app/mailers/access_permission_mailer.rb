
class AccessPermissionMailer < ApplicationMailer
	def user_requested_unlock(perm)
		@permitted = perm.permitted
		@asset_host = ENV["ASSET_HOST"]

		requested = ""
		if perm.profile_requested && !perm.profile_granted
			requested += "profilu"
		end

		if perm.private_photos_requested && !perm.private_photos_granted
			if requested.present?
				requested += "oraz galerii prywantej"
			else
				requested += "galerii prywantej"
			end
		end

		@requested = requested

    mail(
			to: perm.owner.email,
			subject: "Użytkownik prosi o udostępnienie #{@requested}",
			template_path: 'notifications',
			template_name: 'user_requested_unlock'
		)
	end
end