# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
INTERESTS = [
	'Muzyka',
	'Filmy i programy TV',
	'Moda i Uroda',
	'Sport',
	'Podróże',
	'Praca',
	'Gry',
	'Hobby',
	'Książki i Kultura',
	'Jedzenie i Napoje',
	'Przyjaźń',
	'Dobra zabawa',
	'Miłość',
	'Całowanie',
	'Masaże',
	'Pieniądzie'
]

INTERESTS.each do |interest|
	puts interest
	Interest.where(title: interest).first_or_create
end