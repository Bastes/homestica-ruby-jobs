class AddIndexToPractitioners < ActiveRecord::Migration[5.2]
  def change
    add_index :practitioners, %i[first_name last_name]
  end
end
