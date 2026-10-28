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
end
