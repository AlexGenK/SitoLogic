# SQLite's lower() and LIKE fold ASCII only; unicode_lower() folds Cyrillic too
ActiveSupport.on_load(:active_record_sqlite3adapter) do
  prepend(Module.new do
    private
      def configure_connection
        super
        @raw_connection.create_function("unicode_lower", 1) { |func, value| func.result = value&.downcase }
      end
  end)
end
