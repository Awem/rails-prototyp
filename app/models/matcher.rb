class Matcher < ActiveRecord::Base
  has_many :partnerships, dependent: :destroy
  has_many :matched_projects, -> { uniq }, through: :partnerships, source: :project
  has_many :reverse_contributions, -> { matched_payment }, class_name: 'Contribution'
  has_many :supported_projects, -> { uniq }, through: :reverse_contributions, source: :project
  has_many :invoices, dependent: :destroy
  has_many :pictures, as: :theme
  has_many :budgets, dependent: :destroy
  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  default_scope { order(id: :asc) }
  scope :featured_campaign, -> { where(featured: 'campaign') }

  def total_budget(budget = self.budgets.in_effect.take)
    if budget
      budget.amount
    else
      0
    end
  end

  def remaining_budget(budget = self.budgets.in_effect.take)
    if budget
      budget.remains
    else
      0
    end
  end

  def check_budget(budget = self.budgets.in_effect.take)
    if budget
      if budget.remains <= 0.01
        budget.update_attributes(effective: false)
      end
    end
  end

  def matched_projects_count
    self.matched_projects.length
  end

  def supported_contributions_count
    self.reverse_contributions.length
  end

  def supported_projects_count
    self.supported_projects.length
  end

  def payments_to_match
    Payment.need_matching.joins(:matcher).includes(:matcher).where('matcher_id = ?', self.id)
  end

  def get_matching_factor(project_id)
    self.partnerships.find_by(project_id: project_id).factor.to_f
  end

  def matching_factors
    self.matched_projects.map{|p| {p.id => self.get_matching_factor(p.id)}}.reduce(&:merge)
  end

  def create_invoice!(number = '')
    invoice = self.invoices.create!(status: 'open', number: number)
    invoice.contributions = self.payments_to_match.map{|p| p.contribution}
    matched = "invoice-#{invoice.id}"
    self.payments_to_match.update_all(matched: matched)
  end

  def matching?(project)
    partnerships.find_by(project_id: project.id)
  end

  def potential_projects
    Project.where.not(id: self.matched_projects.map(&:id))
  end

  def match!(project, factor = 1)
    partnerships.create!(project_id: project.id, factor: factor)
  end

  def match_payment!(payment_id, factor)
    matched = "times-#{factor}"
    Payment.find(payment_id).update(matched: matched)
  end

  def pay_invoice!(invoice_id)
    invoice = self.invoices.find(invoice_id)
    invoice.contributions.each do |contribution|
      payment_id = contribution.payment.id
      factor = self.get_matching_factor(contribution.project.id)
      self.match_payment!(payment_id, factor)
    end
    invoice.update(status: 'paid')
  end
  
  def unmatch!(project)
    partnerships.find_by(project_id: project.id).destroy
  end

  def set_logo!(picture)
    self.logo = picture.id
    self.save
  end

  def logo_url
    if self.logo != 0
      Picture.find(self.logo).url
    end
  end

  def logo_name
    if self.logo != 0
      Picture.find(self.logo).name
    end
  end
end