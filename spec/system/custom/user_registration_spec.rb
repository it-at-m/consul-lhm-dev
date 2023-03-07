require "rails_helper"

describe "UserRegistration" do
  context "when extended registraion is enabled" do
    before do
      registered_address_street = create(:registered_address_street)
      create_list(:registered_address, 5, registered_address_street: registered_address_street)
    end

    context "when the user is valid" do
      it "creates a user" do
        visit new_user_registration_path
        debugger
        fill_in "Benutzer*innenname", with: "r1"
        fill_in "Email", with: "r1@consul.dev"
      end
    end
  end
end
