class SpecialActions < Hyperloop::Component

  def render
    div(class: "pin-section") do
      img(src:'/assets/password-white-small.png')
      div(class: "pin-text") do
        span(class: "text-book") {"Nadaj PIN składający się z minimum 4 cyfr, który będzie wymagany do odzyskania hasła. Dzięki niemu niepożądane osoby nie będą mogły sprawdzić czy Twój e-mail jest w naszej bazie."}
      end
      form(class: 'form-inline mt-4 mb-4 mt-md-6 mb-md-4') do
        div(class: 'input-group mr-3') do
          input(type: "text", class: "form-control mb-2 mb-sm-0", placeholder: "Minimum 4 znaki")
        end
      end
      button(class: "btn btn-secondary mt-3 mb-3") {'Zapisz PIN'}
    end
  end
end
