class NewsletterSubscriptionsController < ApplicationController
	def create
		@newsletter_subscription = NewsletterSubscription.new(newsletter_subscription_params)
		if @newsletter_subscription.save
			render json: @newsletter_subscription
		else
			render json: @newsletter_subscription.errors.to_json, status: 422
		end
	end

	private

		def newsletter_subscription_params
			params.require(:newsletter_subscription).permit(
				:email
			)
		end
end