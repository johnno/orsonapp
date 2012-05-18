class ApplicationController < ActionController::Base
  protect_from_forgery

  def connect_to_rally(username=nil, password=nil)
    username ||= RALLY_USER
    password ||= RALLY_PASS
    @rally = RallyRestAPI.new(username: username, password: password, version: '1.33')
  end

  def get_last_iteration
    project = @rally.find(:project) { equal :name, 'Fork Handles' }.results.first
    @iteration = @rally.find(:iteration) { 
      equal :project, project
      less_than_equal :start_date, Date.today.to_formatted_s
      greater_than_equal :end_date, Date.today.to_formatted_s 
    }.results.last

    pro_q = project.to_q
    itr_q = @iteration.to_q

    return pro_q, itr_q
  end
end
