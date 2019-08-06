class NewsletterSubscription < ApplicationRecord
  validates :email, :presence => true, :uniqueness => true
end
