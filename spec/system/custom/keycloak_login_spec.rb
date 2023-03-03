require "rails_helper"

describe "Keycloak Login" do
  context "with BayernID" do
    before do
      Setting["feature.bayern_id_login"] = true
      OmniAuth.config.add_mock(:bayern_id, omniauth_bayern_id_hash)
    end

    let(:omniauth_bayern_id_hash) do
      {
        credentials: {
          id_token: "token"
        },
        extra: {
          raw_info: {
            auth_level: "STORK-QAA-Level-3",
            preferred_username: "johndoe"
          }
        },
        info: {
          email: "bayern_id@consul.dev",
          username: "John Doe"
        }
      }
    end

    context "when user was blocked by admin" do
      it "prevents user from signing in" do
        create(:user, email: "bayern_id@consul.dev", hidden_at: Time.current)
        visit new_user_session_path(locale: :de)
        click_button "Alle akzeptieren"
        click_link(title: "Anmelden mit BayernID")
        expect(page).to have_content "Dieses Nutzerkonto existiert bereits, wurde aber von einem Moderator geblockt."
        expect(User.count).to eq(0)
        expect(User.with_hidden.count).to eq(1)
      end
    end

    context "when user signed in with keycloak before" do
      context "without changing his email address in keycloak after first sign in to Consul" do
        it "signs user in successfully" do
          create(:user, email: "bayern_id@consul.dev", keycloak_link: "johndoe")
          visit new_user_session_path(locale: :de)
          click_button "Alle akzeptieren"
          click_link(title: "Anmelden mit BayernID")
          expect(page).to have_content "Erfolgreich angemeldet."
          expect(User.count).to eq(1)
          expect(User.first.keycloak_link).to eq("johndoe")
          expect(User.first.email).to eq("bayern_id@consul.dev")
        end
      end

      context "when email address was changed in keycloak after first sign in to Consul" do
        it "prevents user from signing in when new email is already taken" do
          create(:user, email: "bayern_id_old@consul.dev", keycloak_link: "johndoe")
          create(:user, email: "bayern_id@consul.dev")
          visit new_user_session_path(locale: :de)
          click_button "Alle akzeptieren"
          click_link(title: "Anmelden mit BayernID")
          expect(page).to have_content "Die angegebene E-Mail-Adresse wird bereits verwendet."
          expect(User.count).to eq(2)
        end

        it "signs user in and updates existing user's email address when new email is not taken" do
          create(:user, email: "bayern_id_old@consul.dev", keycloak_link: "johndoe")
          visit new_user_session_path(locale: :de)
          click_button "Alle akzeptieren"
          click_link(title: "Anmelden mit BayernID")
          expect(page).to have_content "Erfolgreich angemeldet."
          expect(User.count).to eq(1)
          expect(User.first.email).to eq("bayern_id@consul.dev")
        end
      end
    end

    context "when user didn't sign in with Keycloak in Consul before" do
      context "when user with the same email coming from Keycloak is already taken in Consul" do
        it "redirects to sign in page and asks user to sign in with email" do
          create(:user, email: "bayern_id@consul.dev", keycloak_link: nil)
          visit new_user_session_path(locale: :de)
          click_button "Alle akzeptieren"
          click_link(title: "Anmelden mit BayernID")
          expect(page).to have_content "Die angegebene E-Mail-Adresse wird bereits verwendet."
          expect(User.count).to eq(1)
          expect(User.first.keycloak_link).to eq(nil)
          expect(User.first.email).to eq("bayern_id@consul.dev")
        end
      end

      it "signs in user successfully when email is not taken" do
        visit new_user_session_path(locale: :de)
        click_button "Alle akzeptieren"
        click_link(title: "Anmelden mit BayernID")
        expect(page).to have_content "Erfolgreich angemeldet."
        expect(User.count).to eq(1)
        expect(User.first.keycloak_link).to eq("johndoe")
        expect(User.first.email).to eq("bayern_id@consul.dev")
      end
    end
  end
end
