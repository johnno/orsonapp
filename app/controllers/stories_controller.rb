class StoriesController < ApplicationController

  PRINT_SERVER = 'http://printer.gofreerange.com/print/2y5m4g5u6s3t8v1r'
  STORY_STATUSES = {
    "NONE" => "DEFINED",
    "DEFINED" => "IN_PROGRESS",
    "IN_PROGRESS" => "COMPLETED",
    "IN_PROGRESS_BLOCKED" => "IN_PROGRESS",
    "COMPLETED_BLOCKED" => "COMPLETED"
  }
  
  before_filter :connect_to_rally
  before_filter :load_all_stories, :only => [:index,:print_all]
  
  def index
  end
  
  def print_all
    @stories.each do |story|
      url_to_print = story_url(story.object_i_d)
      uri = URI.parse(PRINT_SERVER)
      response = Net::HTTP.post_form(uri, {"url" => url_to_print })
    end
    redirect_to stories_path
  end
  
  def show
    story_id = params[:id]
    @story = get_story(story_id)
  end
  
  def qr_code
    scan_url = scanned_story_url(params[:id])
    respond_to do |format|
      format.svg { render text: qr_code_svg(scan_url), content_type: 'image/svg+xml' }
    end
  end
  
  def scanned
    story_id = params[:id]
    @story = get_story(story_id)
    
    next_status = STORY_STATUSES[@story.task_status]
    debugger
    if not next_status.nil?
      @story.update(:task_status => next_status)
    end
    
    render :action => :show
  end
  
  protected

  def get_story(story_id)
    @rally.find(:hierarchical_requirement) do 
      equal :object_i_d, story_id
    end.first
  end
  
  def qr_code_svg(data)
    size   = RQRCode.minimum_qr_size_from_string(data)
    level  = :h
    qrcode = RQRCode::QRCode.new(data, :size => size, :level => level)
    svg    = RQRCode::Renderers::SVG::render(qrcode)
    return svg.to_s
  end
  
  
  def load_all_stories
    pro_q, itr_q = get_last_iteration
    
    @stories = @rally.find(:hierarchical_requirement) do 
      equal(:project, pro_q)
      equal(:iteration, itr_q)
    end.results
  end
  
end
