namespace :diagnostics do
  desc "Print EXPLAIN output for TransactionsController#index query"
  task transactions_query_plan: :environment do
    family  = Family.first || Family.create!(name: "Demo")
    account = Account.first || family.accounts.create!(name: "Demo", balance: 0, currency: "USD", accountable: Depository.new)
    start_date = Date.current - 30

    ActiveRecord::Base.connection.execute("SET enable_seqscan = off")
    ActiveRecord::Base.connection.execute("SET enable_indexscan = on")

    join_sql = "JOIN transactions ON entries.entryable_id = transactions.id AND entries.entryable_type = 'Transaction'"
    query = Entry
              .joins(join_sql)
              .where("entries.date >= ?", start_date)
              .order(date: :desc)

    puts query.explain.inspect
  end
end
