scope module: :verification do
  resource :residence, controller: "residence", only: [:new, :create]
  resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
  resource :verified_user, controller: "verified_user", only: [:show]
  resource :email, controller: "email", only: [:new, :show, :create]
  resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
end

resource :verification, controller: "verification", only: [:show]

get "verification/residence/update_registered_address_street_field",
  to: "verification/residence#update_registered_address_street_field" # custom line
get "verification/residence/update_registered_address_field",
  to: "verification/residence#update_registered_address_field" # custom line
