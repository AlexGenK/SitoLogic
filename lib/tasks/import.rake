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

        nutrient = Nutrient.find_or_initialize_by(code: code.strip)
        nutrient.assign_attributes(
          short_name_en: short_name.strip,
          med_name_en: med_name.strip,
          long_name_en: long_name.strip,
          group: group_name&.downcase&.scan(/[a-z0-9]+/)&.join("_"),
          unit: units[unit_code.strip]
        )
        nutrient.save!(context: :import)
      end
    end

    puts "Imported #{rows.size} nutrients, total #{Nutrient.count}"
  end

  desc "Import nutrient amounts of foods from vendor/db/dpx5db.sl3 food_nutr table"
  task food_nutrients: :environment do
    require "sqlite3"

    path = Rails.root.join("vendor/db/dpx5db.sl3")
    abort "File not found: #{path}" unless File.exist?(path)

    food_ids = Food.pluck(:source_code, :code, :id).to_h { |source, code, id| [ [ source, code ], id ] }
    nutrient_ids = Nutrient.pluck(:code, :id).to_h

    db = SQLite3::Database.new(path.to_s, readonly: true)
    rows = db.execute("SELECT DataSource, FoodCode, NutrId, NutrValue FROM food_nutr")
    # Foods without their own food_nutr rows take the values of their prime food (PrimeSource + PrimeCode)
    derived = db.execute(<<~SQL).each_with_object({}) do |(prime_source, prime_code, source, code), map|
      SELECT f.PrimeSource, f.PrimeCode, f.DataSource, f.FoodCode
      FROM food f
      WHERE NOT (f.PrimeSource = f.DataSource AND f.PrimeCode = f.FoodCode)
        AND NOT EXISTS (
          SELECT 1 FROM food_nutr n WHERE n.DataSource = f.DataSource AND n.FoodCode = f.FoodCode
        )
    SQL
      (map[[ prime_source.strip, prime_code.strip ]] ||= []) << [ source.strip, code.strip ]
    end
    db.close

    imported = inherited = no_nutrient = no_food = 0

    FoodNutrient.transaction do
      rows.each_slice(1000) do |batch|
        records = batch.flat_map do |source, food_code, nutrient_code, value|
          nutrient_id = nutrient_ids[nutrient_code.strip]
          if nutrient_id.nil?
            no_nutrient += 1
            next []
          end

          key = [ source.strip, food_code.strip ]
          [ key, *derived[key] ].filter_map do |target|
            food_id = food_ids[target]
            no_food += 1 if food_id.nil?
            next unless food_id

            inherited += 1 unless target == key
            { food_id: food_id, nutrient_id: nutrient_id, amount: value.strip }
          end
        end

        records.each_slice(1000) do |slice|
          FoodNutrient.upsert_all(slice, unique_by: [ :food_id, :nutrient_id ])
          imported += slice.size
        end
      end
    end

    puts "Imported #{imported} food nutrients from #{rows.size} rows (#{inherited} inherited from prime foods), " \
         "skipped: #{no_nutrient} without nutrient, #{no_food} without food; total #{FoodNutrient.count}"
  end
end
