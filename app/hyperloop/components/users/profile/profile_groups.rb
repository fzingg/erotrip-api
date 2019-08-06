class ProfileGroups < Hyperloop::Component

	param user: {}

	state total: 0
	state current_page: 1
	state per_page: 5

	def render
		groups_scope = params.user.groups

		div(class: "groups") do
			h6(class: "mt-3 mb-3") {'Grupy'}

			groups_scope.limit(state.per_page).offset((state.current_page - 1) * state.per_page).each do |group|
				GroupSingle(group: group, user_group: UserGroup.ransacked(user_id_eq: CurrentUserStore.current_user_id, group_id_eq: group.try(:id)).first)
			end

			Pagination(page: state.current_page,
			  per_page: state.per_page,
			  total: groups_scope.count
			).on :change do |e|
			  page_changed e.to_n
			end

		end
	end

	def page_changed page
	  mutate.current_page page
	end
end