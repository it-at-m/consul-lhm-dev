class Admin::Budgets::TableActionsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def actions_component
      Admin::TableActionsComponent.new(
        budget,
        edit_path: polymorphic_path([namespace, budget]),
        actions: [:edit]
      )
    end
end
