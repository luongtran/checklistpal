PDFKit.configure do |config|

  config.wkhtmltopdf = 'C:\wkhtmltopdf\wkhtmltopdf.exe' if Rails.env == "development"
  config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf' if Rails.env == "production"
  # config.default_options = {
  #   :page_size => 'Legal',
  #   :print_media_type => true
  # }
  # config.root_url = "http://localhost" # Use only if your external hostname is unavailable on the server.
end