module CsvServices
  class FormularAnswersExporter < ApplicationService
    require "csv"

    def initialize(formular)
      @formular = formular
      @formular_answers = @formular.formular_answers
    end

    def call
      CSV.generate(headers: true) do |csv|
        csv << headers

        @formular_answers.each do |formular_answer|
          csv << row(formular_answer)
        end
      end
    end

    private

      def headers
        @formular.formular_fields.map(&:name)
      end

      def row(formular_answer)
        @formular.formular_fields.map do |formular_field|
          formular_answer.answers[formular_field.key]
        end
      end
  end
end
