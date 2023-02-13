module CsvServices
  class PollQuestionAnswersStreetsExporter < ApplicationService
    require "csv"

    def initialize(question)
      @question = question
    end

    def call
      CSV.generate(headers: false, col_sep: ";") do |csv|
        csv << city_street_headers(@question)

        CityStreet.all.find_each do |city_street|
          csv << city_street_row(@question, city_street)
        end
      end
    end

    private

      def city_street_headers(question)
        question.question_answers.map(&:title).unshift(question.title)
      end

      def city_street_row(question, city_street)
        row = []
        row.push(city_street.name)

        question.question_answers.each do |qa|
          answer_count_by_street = question.answers
            .where(answer: qa.title)
            .joins(author: :city_street)
            .where(city_streets: { id: city_street.id })
            .count
          row.push answer_count_by_street
        end

        row
      end
  end
end
