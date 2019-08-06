class UnlocksIndex < Hyperloop::Router::Component

		state current_page: 1
		state per_page: 30

		state search_params: Hash.new

		before_mount do
			mutate.search_params["owner_id_eq"] = CurrentUserStore.current_user_id
			mutate.search_params["sorts"] = ['created_at asc']
		end

		after_mount do
			MobileSearchButtonStore.hide
		end

		def render
			permissions_scope = AccessPermission.ransacked(state.search_params)

			div(class: 'row') do
				div(class: 'col-12 col-xl-9 ml-xl-auto main-content') do

					# HotlineCarousel()

					# UsersSearchBox(users_count: users_scope.count, current_user: CurrentUserStore.current_user).on :change do |e|
					# 	search_changed e.to_n
					# end

					table(class: 'table table-hover mt-4 table-sm table-striped unlocks') do
						thead() do
							tr() do
								th(class: "vertical-middle-i") do
									'Użytkownik'
								end
								th(class: "table-header-resource vertical-middle-i") do
									'Prosi o dostęp do'
								end
								th(class: "vertical-middle-i pull-right") do
									'Akcje'
								end
							end
						end
						tbody() do
							if permissions_scope.loaded?
								permissions_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |access_permission|
									AccessPermissionBlock(permission: access_permission)
								end
							end
						end
					end

					Pagination(
						page: state.current_page,
						per_page: state.per_page,
						total: permissions_scope.count
					).on :change do |e|
						page_changed e.to_n
					end
				end
			end
		end

		# def search_changed terms
		# 	if terms['sorts'] != state.search_params['sorts'] && state.current_page != 1
		# 		mutate.current_page 1
		# 	end
		# 	mutate.search_params terms
		# end

		def page_changed page
			mutate.current_page page
		end
	end