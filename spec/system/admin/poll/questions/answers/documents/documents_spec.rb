require "rails_helper"

describe "Documents", :admin do
  context "Index" do
    xscenario "Answer with no documents" do
      answer = create(:poll_question_answer)
      document = create(:document)

      visit admin_answer_documents_path(answer)

      expect(page).not_to have_content(document.title)
    end

    xscenario "Answer with documents" do
      answer = create(:poll_question_answer)
      document = create(:document, documentable: answer)

      visit admin_answer_documents_path(answer)

      expect(page).to have_content(document.title)
    end
  end

  xscenario "Remove document from answer" do
    answer = create(:poll_question_answer)
    document = create(:document, documentable: answer)

    visit admin_answer_documents_path(answer)
    expect(page).to have_content(document.title)

    accept_confirm("Are you sure? This action will delete \"#{document.title}\" and can't be undone.") do
      click_button "Delete"
    end

    expect(page).not_to have_content(document.title)
  end
end
