module CsvServices
  class PollQuestionAnswersVotesExporter < ApplicationService
    require "csv"

    def initialize(question)
      @question = question
      @poll = question.poll
      @other_poll_questions = @poll.questions.where.not(id: @question.id)
    end

    def call
      CSV.generate(headers: false, col_sep: ";") do |csv|
        csv << headers(@question)

        @other_poll_questions.each do |question|
          question.question_answers.each do |question_answer|
            csv << row(question, question_answer)
          end
        end
      end
    end

    private

      def headers(question)
        headers = []
        headers.push(question.title)
        headers.push("Antworten")
        question.question_answers.each do |qa|
          headers.push("#{qa.title} (#{qa.total_votes})")
          headers.push("%")
        end
        headers
      end

      def row(question, question_answer)
        row = []
        row.push(question.title)
        row.push(question_answer.title)

        @question.question_answers.each do |base_question_answer|
          row.push question_answer.total_connected_votes_to(base_question_answer)
          row.push question_answer.total_connected_votes_inner_share(base_question_answer).round(2)
        end

        row
      end
  end
end
