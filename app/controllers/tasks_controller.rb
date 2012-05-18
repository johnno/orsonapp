require 'net/http'

class TasksController < ApplicationController

  before_filter :authenticate_user!
  before_filter :has_set_rally_credentials!

  def index
    connect_to_rally(current_user.rally_email, current_user.rally_password)

    pro_q, itr_q = get_last_iteration

    @stories = @rally.find(:hierarchical_requirement) do
      equal(:project, pro_q)
      equal(:iteration, itr_q)
      greater_than_equal(:task_status, 'DEFINED')
      not_equal(:task_status, 'COMPLETED')
    end.results
  end


  def assign
    task_id = params[:id]

    #task = Task.new(:user_id => current_user,
                    #:rally_task_id => task_id,
                    #:state => "In-Progress")
    #task.save

    connect_to_rally(current_user.rally_email, current_user.rally_password)

    pro_q, itr_q = get_last_iteration

    task = @rally.find(:task) do
      equal(:project, pro_q)
      equal(:iteration, itr_q)
      equal(:object_i_d, task_id)
    end.results.first



    data = StringIO.new
    printer = A2Printer.new(data)
    printer.begin
    printer.set_default
    printer.println(task.name)
    printer.qrcode(task_id)

    uri = URI("http://olly.oesmith.co.uk:4567/printer/2y5m4g5u6s3t8v1r")
    #raise "#{uri.host}, #{uri.port}, #{uri.path}"
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = data.string
    req.content_type = "application/data"

    res = Net::HTTP.start(uri.host, uri.port) { |http|
      http.request(req)
    }

    puts res

    task.update(state: "In-Progress")

    redirect_to tasks_path
  end

  protected

  def has_set_rally_credentials!
    if current_user.rally_email.nil? || current_user.rally_password.nil?
      redirect_to edit_user_registration_path
    end
  end

end
