class RootController < ApplicationController
  
  helper_method :qr_code_image64
  def index
  end
  
  def qr_code_image64
    ""
  end
  
  
  def qr_code_data
    'http://www.johnno.com'
  end
  
  def qr_code_image
    size   = RQRCode.minimum_qr_size_from_string(qr_code_data)
    level  = :h
    qrcode = RQRCode::QRCode.new(qr_code_data, :size => size, :level => level)
    svg    = RQRCode::Renderers::SVG::render(qrcode)
    image  = MiniMagick::Image.read(svg) { |i| i.format "svg" }
    image.format "png"
    image.to_blob
  end
  
  def qr_code_image64
    Base64.encode64(qr_code_image)
  end
  
end
