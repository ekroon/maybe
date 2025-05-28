module QueryTestHelper
  # Assert no duplicate SQL queries (normalized) are executed within the block.
  # Normalization removes quoted integers to account for id variations.
  def assert_no_duplicate_normalized_queries
    queries = []

    callback = lambda do |_name, _start, _finish, _message_id, payload|
      sql = payload[:sql]
      next if sql =~ /\A(?:PRAGMA |SAVEPOINT|RELEASE|ROLLBACK TO|BEGIN TRANSACTION|COMMIT TRANSACTION)/
      next if payload[:name] == "SCHEMA"

      queries << sql
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      yield
    end

    normalized = queries.map { |q| q.squish.gsub(/\b\d+\b/, "?") }
    duplicates = normalized.group_by(&:itself).select { |_k, v| v.size > 1 }
    assert duplicates.empty?, "Duplicate queries detected:\n#{duplicates.keys.join("\n")}"
  end
end

