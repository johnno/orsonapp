class StoriesController < ApplicationController

  PRINT_SERVER = 'http://printer.gofreerange.com/print/2y5m4g5u6s3t8v1r'
  
  before_filter :connect_to_rally
  before_filter :load_all_stories, :only => [:index,:print_all]
  
  def index
  end
  
  def print_all
    @stories.each do |story|
      url_to_print = story_url(story.formatted_i_d)
      uri = URI.parse(PRINT_SERVER)
      response = Net::HTTP.post_form(uri, {"url" => url_to_print })
    end
    redirect_to stories_path
  end
  
  def show
    story_id = params[:id]
    @story = @rally.find(:hierarchical_requirement) do 
      equal :object_i_d, story_id
    end.first
  end
  
  def qr_code
    scan_url = scanned_story_url(params[:id])
    respond_to do |format|
      format.svg { render text: qr_code_svg(scan_url), content_type: 'image/svg+xml' }
    end
  end
  
  protected
  
  def qr_code_svg(data)
    size   = RQRCode.minimum_qr_size_from_string(data)
    level  = :h
    qrcode = RQRCode::QRCode.new(data, :size => size, :level => level)
    svg    = RQRCode::Renderers::SVG::render(qrcode)
    return svg.to_s
  end
  
  def connect_to_rally
    @rally = RallyRestAPI.new(username: RALLY_USER, password: RALLY_PASS)
  end
  
  def load_all_stories
    project = @rally.find(:project) { equal :name, 'Fork Handles' }.results.first
    @iteration = @rally.find(:iteration) { 
      equal :project, project
      less_than_equal :start_date, Date.today.to_formatted_s
      greater_than_equal :end_date, Date.today.to_formatted_s 
    }.results.last

    # to_q is usually called internally by code in the block if you do equal(:project, project) etc
    # but it is bugger in that context so we call it outside the block here and all is fun
    pro_q = project.to_q
    itr_q = @iteration.to_q
    
    @stories = @rally.find(:hierarchical_requirement) do 
      equal(:project, pro_q)
      equal(:iteration, itr_q)
    end.results
  end
  
end