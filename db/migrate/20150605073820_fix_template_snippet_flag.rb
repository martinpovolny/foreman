class FixTemplateSnippetFlag < ActiveRecord::Migration
  class FakeTemplate < ActiveRecord::Base
    self.table_name = 'templates'
  end

  def up
    FakeTemplate.where(:snippet => nil).all.each do |template|
      template.update_attribute :snippet, false
    end

    change_column :templates, :snippet, :boolean, :default => false, :null => false
  end

  def down
    change_column :templates, :snippet, :boolean, :null => true
  end
end
