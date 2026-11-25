class FoldCatalogTextForSearch < ActiveRecord::Migration[8.1]
  def change
    add_column :artists, :search_name, :string, null: false, default: ""
    add_column :tracks, :search_text, :text, null: false, default: ""

    up_only do
      connection.select_rows("SELECT id, name FROM artists").each do |id, name|
        connection.execute("UPDATE artists SET search_name = #{connection.quote(name.downcase(:fold))} WHERE id = #{Integer(id)}")
      end
      connection.select_rows("SELECT id, title, genre FROM tracks").each do |id, title, genre|
        text = "#{title}\n#{genre}".downcase(:fold)
        connection.execute("UPDATE tracks SET search_text = #{connection.quote(text)} WHERE id = #{Integer(id)}")
      end
    end
  end
end
