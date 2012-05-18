class TasksController < ApplicationController

  before_filter :authenticate_user!
  before_filter :has_set_rally_credentials!

  def index
    connect_to_rally(current_user.rally_email, current_user.rally_password)

    pro_q, itr_q = get_last_iteration

    @stories = @rally.find(:hierarchical_requirement) do
      equal(:project, pro_q)
      equal(:iteration, itr_q)
      equal(:task_status, 'DEFINED')
    end.results

  end

  protected

  def has_set_rally_credentials!
    if current_user.rally_email.nil? || current_user.rally_password.nil?
      redirect_to edit_user_registration_path
    end
  end

end
