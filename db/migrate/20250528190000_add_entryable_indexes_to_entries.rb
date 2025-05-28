class AddEntryableIndexesToEntries < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :entries, [:entryable_type, :entryable_id], algorithm: :concurrently
    add_index :entries, [:entryable_type, :entryable_id, :date], algorithm: :concurrently
  end
end
