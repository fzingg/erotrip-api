class TruncateModelsDescriptions < ActiveRecord::Migration[5.1]
  def up
      # Trip.all.each { |t| t.update_column(:description, t.description.truncate(140, separator: ' ')) }
      # Hotline.all.each { |h| h.update_column(:content, h.content.truncate(140, separator: ' ')) }
      # Group.all.each { |g| g.update_column(:desc, g.desc.truncate(140, separator: ' ')) }
      # User.all.each { |u| u.update_column(:my_expectations, u.my_expectations.truncate(50, separator: ' ')) }

      Trip.all.each { |t| t.update_column(:description, t.description[0...140]) if t.try(:description) }
      Hotline.all.each { |h| h.update_column(:content, h.content[0...140]) if h.try(:content)}
      Group.all.each { |g| g.update_column(:desc, g.desc[0...140]) if g.try(:desc) }
      User.all.each { |u| u.update_column(:my_expectations, u.my_expectations[0...50]) if u.try(:my_expectations)  }
  end
end
