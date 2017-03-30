class Contribution < ActiveRecord::Base
  include PaypalApi
  belongs_to :user
  belongs_to :project
  belongs_to :matcher
  belongs_to :invoice
  belongs_to :budget
  has_one :trip, dependent: :destroy
  has_one :payment, dependent: :destroy
  accepts_nested_attributes_for :trip, allow_destroy: true
  # validates :user_id, presence: true
  validates :title, presence: true, length: { maximum: 140 }
  scope :paid_payment, -> { where(id: Payment.paid.select(:contribution_id).uniq) }
  scope :matched_payment, -> { where(id: Payment.matched.select(:contribution_id).uniq) }
  scope :has_payment, -> { where(id: Payment.select(:contribution_id).uniq) }
  scope :no_payment, -> { where.not(id: Payment.select(:contribution_id).uniq) }
  scope :has_trip, -> { where.not(trip_id: nil) }
  scope :no_trip, -> { where(trip_id: nil) }
  before_save :assign_budget

  def pay(payment_params)
    if Contribution.has_payment.exists?(self.id)
      self.errors.add(:paying, 'denied. This contribution has already been already paid')
      false
    else
      # Build request object
      pay = paypal_api.build_pay({
        actionType: 'PAY',
        cancelUrl: 'http://localhost',
        currencyCode: 'EUR',
        ipnNotificationUrl: 'http://localhost',
        feesPayer: 'EACHRECEIVER',
        memo: self.project.name,
        receiverList: {
          receiver: [{
            amount: self.amount,
            email: self.project.paypal_account
          }]
        },
        returnUrl: 'http://localhost'
      })

      # Make API call & get response
      response = paypal_api.pay(pay)

      # Access response
      if response.success? && response.payment_exec_status != 'ERROR'
        paypal_data = {payload: pay.to_json, response: response.to_json, status: response.paymentExecStatus}
        build_params = payment_params.permit(:provider).merge(paypal_data)
        # build_params.permit(:provider, :payload, :response, :status)
        self.build_payment(build_params)
      else
        logger.error response.error[0].message
      end
    end
  end

  def check_payment
    if self.payment
      self.payment.check
    else
      'no payment'
    end
  end

  def assign_budget(budget = nil)
    unless budget
      if self.try(:matcher).try(:budgets).try(:in_effect).try(:take)
        budget = self.matcher.budgets.in_effect.take
      else
        return self.budget = nil
      end
    end
    if budget.remains >= self.amount
      self.budget = budget
    else
      # TODO: Add more sophisticated handling of this case later
      logger.warn 'Budget exceeded!'
      self.budget = nil
    end
  end
end
