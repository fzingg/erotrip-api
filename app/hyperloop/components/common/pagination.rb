class Pagination < Hyperloop::Router::Component
  state current_page: 1

  param page_window: 5
  param page: 1
  param per_page: 25
  param total: 0
	param onChange: nil

  before_update do
    if params.page != state.current_page
      mutate.current_page params.page
      if React::IsomorphicHelpers.on_opal_client?
        `window.scrollTo(0,0)`
      end
    end
  end

  after_mount do
    mutate.current_page params.page if params.page != state.current_page
	end

	before_receive_props do |new_props|
		mutate.current_page new_props[:page] if new_props[:page].present?
	end

  def go_to_page(page_no)
    mutate.current_page page_no
    params.onChange.call(state.current_page) if params.onChange.present?
  end

  def is_there_page page_no
    val = page_no > 0 && (page_no - 1) * params.per_page < params.total
    val
  end

	def shown_pages

    # arr = [state.current_page]

    # arr.push state.current_page - 2 if is_there_page(state.current_page - 2)
    # arr.push state.current_page - 1 if is_there_page(state.current_page - 1)


    # arr.push state.current_page + 1 if is_there_page(state.current_page + 1)
    # arr.push state.current_page + 2 if is_there_page(state.current_page + 2)


    # if arr.length < params.page_window
    #   if is_there_page(state.current_page - 3)
    #     (1..(params.page_window - arr.length)).to_a.each do |i|
    #       arr.push state.current_page - (2 + i) if is_there_page(state.current_page - (2 + i))
    #     end
    #   elsif is_there_page(state.current_page + 3)
    #     (1..(params.page_window - arr.length)).to_a.each do |i|
    #       arr.push state.current_page + (2 + i) if is_there_page(state.current_page + (2 + i))
    #     end
    #   end
    # end

		# arr.sort

		number_of_pages = (params.total.to_f / params.per_page.to_f).ceil
		pages = []

		if state.current_page < 7
			i = 1
			while (i <= number_of_pages && i <= 7) do
				pages << { type: 'item', page: i }
				i += 1
			end
		else
			i = state.current_page - 2
			pages << { type: 'item', page: 1 }
			pages << { type: 'more', page: state.current_page - 5 }
			while (i <= number_of_pages && i <= state.current_page + 2) do
				pages << { type: 'item', page: i }
				i += 1
			end

			if (state.current_page + 5) < number_of_pages
				pages << { type: 'more', page: state.current_page + 5 }
			end
		end

		pages
  end

  def render
    span do
      if params.total > 0 && is_there_page(2)
        nav(class: 'mt-5 mb-5') do
          ul(class: 'pagination justify-content-between') do

            li(class: "page-item previous #{'disabled' if state.current_page == 1}") do
              a(class: 'page-link justify-content-center', href:"#") do
                i(class: 'ero-chevron-left-rounded mr-0 mr-md-2')
                span(class: 'd-none d-md-inline-block') {'Poprzednia strona'}
              end.on :click do |e|
                e.prevent_default
                go_to_page(state.current_page - 1)
              end
            end

            div(class: 'page-wrapper') do
              shown_pages.each do |page|
                li(class: "page-item #{'more' if page[:type] == 'more'} #{'active' if state.current_page == page[:page]}") do
									a(class: 'page-link', href: "#") do
										page[:type] == 'item' ? page[:page].to_s : '...'
                  end.on :click do |e|
                    e.prevent_default
                    go_to_page(page[:page])
                  end
                end
              end
            end

            li(class: "page-item next #{'disabled' if !is_there_page(state.current_page + 1)}") do
              a(class: 'page-link justify-content-center', href:"") do
                span(class: 'd-none d-md-inline-block') {'Następna strona'}
                i(class: 'ero-chevron-right-rounded ml-0 ml-md-2')
              end.on :click do |e|
                e.prevent_default
                go_to_page(state.current_page + 1) if is_there_page(state.current_page + 1)
              end
            end
          end
        end
      end
    end
  end

end