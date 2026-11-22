# PDF of the menu report: the overview as label / value rows, then the nutrient table grouped like the page.
# DejaVu Sans covers Cyrillic, Prawn's built-in fonts do not.
class MenuReportPdf
  FONT_DIR = Rails.root.join("vendor/fonts")
  MUTED = "6C757D"
  BORDER = "DEE2E6"
  TINT = "F1F3F5"
  # Nutrient table: name, unit, then four amounts, in shares of the page width
  NUTRIENT_WIDTHS = [ 0.4, 0.08, 0.13, 0.13, 0.13, 0.13 ].freeze

  def initialize(title:, rows:, nutrients_title:, nutrients_header:, nutrients:)
    @title = title
    @rows = rows
    @nutrients_title = nutrients_title
    @nutrients_header = nutrients_header
    @nutrients = nutrients
  end

  def render
    document = Prawn::Document.new(page_size: "A4", margin: 40, info: { Title: @title })
    document.font_families.update("DejaVu" => {
      normal: FONT_DIR.join("DejaVuSans.ttf").to_s,
      bold: FONT_DIR.join("DejaVuSans-Bold.ttf").to_s
    })
    document.font "DejaVu", size: 11

    document.text @title, size: 16, style: :bold
    document.move_down 12
    overview(document)
    nutrient_table(document) if @nutrients.any?

    document.render
  end

  private
    def overview(document)
      document.table(@rows, width: document.bounds.width,
                     column_widths: { 0 => document.bounds.width * 0.4 },
                     cell_style: { borders: [ :bottom ], border_color: BORDER, padding: [ 6, 8 ] }) do
        column(0).text_color = MUTED
      end
    end

    def nutrient_table(document)
      document.move_down 20
      document.text @nutrients_title, size: 14, style: :bold
      document.move_down 8

      header = @nutrients_header.map.with_index { |text, index| amount_cell(text, index).merge(font_style: :bold, background_color: TINT) }
      body = @nutrients.flat_map do |group, rows|
        [ [ { content: group, colspan: 6, font_style: :bold, background_color: TINT } ] ] +
          rows.map { |row| row.map.with_index { |text, index| amount_cell(text, index) } }
      end

      width = document.bounds.width
      document.table([ header, *body ], header: true, width:,
                     column_widths: NUTRIENT_WIDTHS.map { it * width },
                     cell_style: { size: 9, borders: [ :bottom ], border_color: BORDER, padding: [ 4, 6 ] })
    end

    # Amount columns (third onward) are right-aligned
    def amount_cell(text, index)
      { content: text, align: index >= 2 ? :right : :left }
    end
end
