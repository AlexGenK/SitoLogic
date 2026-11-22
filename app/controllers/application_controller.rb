class ApplicationController < ActionController::Base
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  http_basic_authenticate_with name: Rails.application.credentials.dig(:admin_login),
    password: Rails.application.credentials.dig(:admin_password), unless: -> { Rails.env.test? }

  private
    # Sources chosen in the food filter; without the sources param, the defaults from the settings.
    # The filter always sends an empty sources[] value, so unchecking all sources searches all of them.
    def selected_source_codes
      return Setting.current.default_source_codes unless params.key?(:sources)

      Array.wrap(params[:sources]).grep(String).compact_blank
    end
end
