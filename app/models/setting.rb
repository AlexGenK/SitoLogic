# Application settings: a single row, one column per setting
class Setting < ApplicationRecord
  normalizes :default_source_codes, with: -> { Array.wrap(it).grep(String).compact_blank.uniq }

  validate :default_sources_exist

  # The only settings row, created with column defaults on first use
  def self.current
    first || create!
  end

  def default_sources
    Source.where(code: default_source_codes)
  end

  private
    def default_sources_exist
      unknown = default_source_codes - Source.where(code: default_source_codes).pluck(:code)
      errors.add(:default_source_codes, :inclusion) if unknown.any?
    end
end
