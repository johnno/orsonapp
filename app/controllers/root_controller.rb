class RootController < ApplicationController

  require 'barby'
  require 'barby/barcode/ean_13'
  require 'barby/barcode/code_39'
  # require 'barby/outputter/png_outputter'
  require 'barby/outputter/svg_outputter'
  
  
  helper_method :qr_code_image64
  def index
    rally = RallyRestAPI.new(username: RALLY_USER, password: RALLY_PASS)
    project = rally.find(:project) { equal :name, 'Fork Handles' }.results.first
    @iteration = rally.find(:iteration) { 
      equal :project, project
      less_than_equal :start_date, Date.today.to_formatted_s
      greater_than_equal :end_date, Date.today.to_formatted_s 
    }.results.last

    # to_q is usually called internally by code in the block if you do equal(:project, project) etc
    # but it is bugger in that context so we call it outside the block here and all is fun
    pro_q = project.to_q
    itr_q = @iteration.to_q
    
    @stories = rally.find(:hierarchical_requirement) do 
      equal(:project, pro_q)
      equal(:iteration, itr_q)
    end.results
  end
  
  def qr_code
    respond_to do |format|
      format.svg { render text: qr_code_image, content_type: 'image/svg+xml' }
      format.png { render text: qr_code_png, content_type: 'image/png' }
    end
  end
  
  def barcode
    code = Barby::Code39.new('1234567',true)
    respond_to do |format|
      format.svg { render text: code.to_svg(:height => 50, :margin => 5), content_type: 'image/svg+xml' }
      format.png { render text: code.to_png(:height => 50, :margin => 5) , content_type: 'image/png' }
    end
  end
  
  protected
  
  def qr_code_data
    'http://www.johnno.com'
  end
  
  def qr_code_image
    size   = RQRCode.minimum_qr_size_from_string(qr_code_data)
    level  = :h
    qrcode = RQRCode::QRCode.new(qr_code_data, :size => size, :level => level)
    svg    = RQRCode::Renderers::SVG::render(qrcode)
    return svg.to_s
    
  end
  
  def qr_code_png
    image  = MiniMagick::Image.read(qr_code_image) { |i| i.format "svg" }
    image.format "png"
    image.to_blob
  end
  
  def qr_code_image64
    Base64.encode64(qr_code_image)
  end
  
end

