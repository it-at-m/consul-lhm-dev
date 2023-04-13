module CsvServices
  class PollQuestionAnswersStreetsExporter < ApplicationService
    require "csv"

    def initialize(question)
      @question = question
    end

    def call
      CSV.generate(headers: false, col_sep: ";") do |csv|
        csv << street_headers(@question)

        RegisteredAddress::Street.find_each do |street|
          csv << street_row(@question, street)
        end
      end
    end

    private

      def street_headers(question)
        question.question_answers.map(&:title).unshift(question.title)
      end

      def street_row(question, street)
        row = []
        row.push(street.name)

        question.question_answers.each do |qa|
          answer_count_by_street = question.answers
            .where(answer: qa.title)
            .joins(author: [registered_address: :registered_address_street])
            .where(registered_address_streets: { id: street.id })
            .count
          row.push answer_count_by_street
        end

        row
      end
  end
end
