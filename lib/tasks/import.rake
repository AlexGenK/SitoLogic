namespace :import do
  desc "Import sources (RefType = 'SRC') from vendor/db/dpx5db.sl3 reference table"
  task sources: :environment do
    require "sqlite3"

    path = Rails.root.join("vendor/db/dpx5db.sl3")
    abort "File not found: #{path}" unless File.exist?(path)

    db = SQLite3::Database.new(path.to_s, readonly: true)
    rows = db.execute(<<~SQL)
      SELECT s.Code, s.Name, g.Name
      FROM reference s
      LEFT JOIN reference g ON g.RefType = 'GLN' AND g.Code = s.Code
      WHERE s.RefType = 'SRC'
    SQL
    db.close

    Source.transaction do
      rows.each do |code, name, group_type|
        Source.find_or_initialize_by(code: code.strip)
              .update!(name_en: name.strip, group_type: group_type&.strip)
      end
    end

    puts "Imported #{rows.size} sources, total #{Source.count}"
  end

  desc "Import food groups (GPM, GPS, GPT, GPU, GPE, G10) from vendor/db/dpx5db.sl3 reference table"
  task groups: :environment do
    require "sqlite3"

    path = Rails.root.join("vendor/db/dpx5db.sl3")
    abort "File not found: #{path}" unless File.exist?(path)

    db = SQLite3::Database.new(path.to_s, readonly: true)
    rows = db.execute(<<~SQL)
      SELECT RefType, Code, Name FROM reference
      WHERE RefType IN (SELECT DISTINCT Name FROM reference WHERE RefType = 'GLN')
    SQL
    db.close

    Group.transaction do
      rows.each do |group_type, code, name|
        Group.find_or_initialize_by(group_type: group_type.strip, code: code.strip)
             .update!(name_en: name.strip)
      end
    end

    puts "Imported #{rows.size} groups, total #{Group.count}"
  end

  desc "Import nutrients (TypeCode = 'S', ClassCode not starting with 00) from vendor/db/dpx5db.sl3"
  task nutrients: :environment do
    require "sqlite3"

    units = { "2" => :ug, "3" => :mg, "4" => :g, "5" => :kj, "6" => :kcal, "9" => :ui, "10" => :kg_per_l }
    parent_prefixes = { "21" => "20", "22" => "20", "23" => "20", "24" => "20", "62" => "61" }

    path = Rails.root.join("vendor/db/dpx5db.sl3")
    abort "File not found: #{path}" unless File.exist?(path)

    db = SQLite3::Database.new(path.to_s, readonly: true)
    headers = db.execute("SELECT ClassCode, LongName FROM nutrient WHERE TypeCode = 'T'")
                .to_h { |class_code, name| [ class_code.first(2), name.strip ] }
    rows = db.execute(<<~SQL)
      SELECT NutrId, ClassCode, ShortName, MedName, LongName, UnitCode
      FROM nutrient
      WHERE TypeCode = 'S' AND ClassCode NOT LIKE '00%'
    SQL
    db.close

    Nutrient.transaction do
      rows.each do |code, class_code, short_name, med_name, long_name, unit_code|
        prefix = class_code.first(2)
        group_name = headers[parent_prefixes.fetch(prefix, prefix)]

        Nutrient.find_or_initialize_by(code: code.strip).update!(
          short_name_en: short_name.strip,
          med_name_en: med_name.strip,
          long_name_en: long_name.strip,
          group: Nutrient.groups.key(group_name),
          unit: units[unit_code.strip]
        )
      end
    end

    puts "Imported #{rows.size} nutrients, total #{Nutrient.count}"
  end
end
