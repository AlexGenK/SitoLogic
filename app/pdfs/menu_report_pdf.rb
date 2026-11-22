# PDF of the menu report: a title and a table of label / value rows. DejaVu Sans covers Cyrillic,
# Prawn's built-in fonts do not.
class MenuReportPdf
  FONT_DIR = Rails.root.join("vendor/fonts")
  MUTED = "6C757D"
  BORDER = "DEE2E6"

  def initialize(title:, rows:)
    @title = title
    @rows = rows
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
    document.table(@rows, width: document.bounds.width,
                   column_widths: { 0 => document.bounds.width * 0.4 },
                   cell_style: { borders: [ :bottom ], border_color: BORDER, padding: [ 6, 8 ] }) do
      column(0).text_color = MUTED
    end

    document.render
  end
end
