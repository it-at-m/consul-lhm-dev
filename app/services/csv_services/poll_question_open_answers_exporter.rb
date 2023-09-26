module CsvServices
  class PollQuestionOpenAnswersExporter < ApplicationService
    require "csv"

    def initialize(question)
      @question = question
      @question_answer_with_open_answers = question.question_answers.find_by(open_answer: true)
      @open_answers = Poll::Answer.where(question_id: @question.id, answer: @question_answer_with_open_answers.title)
    end

    def call
      CSV.generate(headers: false, col_sep: ";") do |csv|
        csv << headers(@question)

        @open_answers.each do |open_answer|
          csv << row(open_answer)
        end
      end
    end

    private

      def headers(question)
        headers = []
        headers.push(question.title)
        headers.push("Antworten")
        headers
      end

      def row(open_answer)
        row = []
        row.push("")
        row.push(open_answer.open_answer_text)
        row
      end
  end
end
