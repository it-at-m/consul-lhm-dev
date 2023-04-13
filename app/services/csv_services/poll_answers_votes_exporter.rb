module CsvServices
  class PollAnswersVotesExporter < ApplicationService
    require "csv"

    def initialize(poll)
      @poll = poll
    end

    def call
      CSV.generate(headers: false, col_sep: ";") do |csv|
        @poll.questions.each do |question|
          csv << question_headers(question)

          question.question_answers.each do |question_answer|
            csv << row(question_answer)
          end

          csv << []
        end
      end
    end

    private

      def question_headers(question)
        headers = []
        headers.push(question.title)
        headers.push("Stimmenanzahl")
        headers.push("%")
        headers
      end

      def row(question_answer)
        row = []
        row.push question_answer.title
        row.push question_answer.total_votes
        row.push question_answer.total_votes_percentage.round(2)
        row
      end
  end
end
