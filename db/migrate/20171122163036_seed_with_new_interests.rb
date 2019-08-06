class SeedWithNewInterests < ActiveRecord::Migration[5.1]
	def change
		new_interests = [
			"Cyber seks",
			"Dłuższa znajomość",
			"Flirt",
			"Miłość",
			"Przyjaźń",
			"Realne spotkania",
			"Romans",
			"Seks bez zobowiązań",
			"Szukam sponsora",
			"Zasponsoruję"
		]

		puts "Deleting all Interest records and UserInterest using destroy_all"
		Interest.destroy_all

		puts "Populating database with new Interest records"
		ActiveRecord::Base.connection.execute("INSERT INTO interests (title) VALUES #{new_interests.map{ |interest| "('#{interest}')" }.join(",")};")
  end
end