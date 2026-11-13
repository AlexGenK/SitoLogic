class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  http_basic_authenticate_with name: Rails.application.credentials.dig(:admin_login), password: Rails.application.credentials.dig(:admin_password)
end
