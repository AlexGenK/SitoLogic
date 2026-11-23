# PDF of the menu report: the overview as label / value rows, the nutrient table grouped like the page and the
# menu's foods. DejaVu Sans covers Cyrillic, Prawn's built-in fonts do not.
class MenuReportPdf
  FONT_DIR = Rails.root.join("vendor/fonts")
  MUTED = "6C757D"
  BORDER = "DEE2E6"
  TINT = "F1F3F5"
  # Column widths in shares of the page width, and the right-aligned amount columns
  NUTRIENT_WIDTHS = [ 0.4, 0.08, 0.13, 0.13, 0.13, 0.13 ].freeze
  NUTRIENT_AMOUNTS = 2..5
  FOOD_WIDTHS = [ 0.12, 0.12, 0.13, 0.13, 0.5 ].freeze
  FOOD_AMOUNTS = 2..3

  # nutrients: { title:, header:, groups: [[label, rows]] }; foods: { title:, header:, rows:, total: }; cells are text
  def initialize(title:, rows:, nutrients:, foods:)
    @title = title
    @rows = rows
    @nutrients = nutrients
    @foods = foods
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
    nutrient_table(document) if @nutrients[:groups].any?
    food_table(document) if @foods[:rows].any?

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
      section_title(document, @nutrients[:title])
      header = cells(@nutrients[:header], NUTRIENT_AMOUNTS, font_style: :bold, background_color: TINT)
      body = @nutrients[:groups].flat_map do |group, rows|
        [ [ { content: group, colspan: NUTRIENT_WIDTHS.size, font_style: :bold, background_color: TINT } ] ] +
          rows.map { cells(it, NUTRIENT_AMOUNTS) }
      end
      grid(document, [ header, *body ], NUTRIENT_WIDTHS)
    end

    def food_table(document)
      section_title(document, @foods[:title])
      header = cells(@foods[:header], FOOD_AMOUNTS, font_style: :bold, background_color: TINT)
      body = @foods[:rows].map { cells(it, FOOD_AMOUNTS) }
      total = cells(@foods[:total], FOOD_AMOUNTS, font_style: :bold)
      grid(document, [ header, *body, total ], FOOD_WIDTHS)
    end

    def section_title(document, text)
      document.move_down 20
      document.text text, size: 14, style: :bold
      document.move_down 8
    end

    # A table with the header row repeated on every page, small type and bottom borders
    def grid(document, data, widths)
      width = document.bounds.width
      document.table(data, header: true, width:, column_widths: widths.map { it * width },
                     cell_style: { size: 9, borders: [ :bottom ], border_color: BORDER, padding: [ 4, 6 ] })
    end

    # Cells of a row; the columns in amounts are right-aligned
    def cells(row, amounts, **style)
      row.map.with_index { |text, index| { content: text, align: amounts.cover?(index) ? :right : :left, **style } }
    end
end
