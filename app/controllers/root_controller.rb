class RootController < ApplicationController

  require 'barby'
  require 'barby/barcode/ean_13'
  require 'barby/barcode/code_39'
  # require 'barby/outputter/png_outputter'
  require 'barby/outputter/svg_outputter'
  
  
  helper_method :qr_code_image64
  def index
    # rally = RallyRestAPI.new(username: RALLY_USER, password: RALLY_PASS)
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
