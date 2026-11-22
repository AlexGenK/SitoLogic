class SettingsController < ApplicationController
  before_action :set_setting
  before_action :set_sources

  def edit
  end

  def update
    if @setting.update(setting_params)
      redirect_to edit_settings_path, notice: t(".saved")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_setting
      @setting = Setting.current
    end

    def set_sources
      @sources = Source.with_foods_count.order("foods_count DESC", :code)
    end

    def setting_params
      params.expect(setting: [ default_source_codes: [] ])
    end
end
