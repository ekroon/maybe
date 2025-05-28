require "test_helper"

class EntryIndexesTest < ActiveSupport::TestCase
  include EntriesTestHelper

  test "transactions query uses entryable index" do
    account = accounts(:depository)
    create_transaction(account: account, date: Date.current)

    ActiveRecord::Base.connection.execute("SET enable_seqscan = off")

    query = Entry
              .joins("JOIN transactions ON entries.entryable_id = transactions.id")
              .where(entryable_type: "Transaction", account_id: account.id)
              .where("entries.date >= ?", Date.current - 5)
              .order(date: :desc)
              .limit(1)

    plan = query.explain.inspect

    assert_includes plan, "index_entries_on_entryable_type_and_entryable_id"
  end
end
