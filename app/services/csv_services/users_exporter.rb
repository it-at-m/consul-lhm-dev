module CsvServices
  class UsersExporter < ApplicationService
    require "csv"
    include AdminHelper

    def initialize(users)
      @users = users
    end

    def call
      CSV.generate(headers: true) do |csv|
        csv << headers

        @users.each do |user|
          csv << row(user)
        end
      end
    end

    private

      def headers
        [
          "Id", "Username", "Email", "Vorname", "Nachname",
          "Stadt", "Adresse", "Postleitzahl", "Gebiet",
          "Dokument", "Dokument (4 letzten Ziffern)", "Nutzer angelegt am",
          "Geschlecht", "Geburtsdatum", "Rollen", "Unique Stamp", "Verifiziert am"
        ]
      end

      def row(user)
        user_row = [
          user.id, user.name, user.email, user.first_name, user.last_name,
          user.city_name, user.formatted_address, user.plz, user.geozone&.name,
          user.document_type, user.document_last_digits, I18n.l(user.created_at, format: "%d %b %Y")
        ]

        user_row.push(user.gender.present? ? I18n.t("custom.devise_views.users.gender.#{user.gender}") : "")
        user_row.push(user.date_of_birth.present? ? I18n.l(user.date_of_birth, format: "%d %b %Y") : "")
        user_row.push(display_user_roles(user))
        user_row.push(user.unique_stamp.to_s)
        user_row.push(user.verified_at.present? ? I18n.l(user.verified_at, format: "%d %b %Y") : "")

        user_row
      end
  end
end
