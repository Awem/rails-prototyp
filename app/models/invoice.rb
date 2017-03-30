class Invoice < ActiveRecord::Base
  belongs_to :matcher
  has_many :contributions

  def positions
    self.contributions.map{|c| {c.project.id => (c.amount * self.matching_factor(c.project.id))}}.inject{|sum, amount| sum.merge(amount){|k, v1, v2| v1 + v2}}
  end

  def matching_factor(project_id)
    self.matcher.get_matching_factor(project_id)
  end
end
