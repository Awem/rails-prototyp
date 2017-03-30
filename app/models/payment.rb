class Payment < ActiveRecord::Base
  include PaypalApi
  belongs_to :contribution
  has_one :project, through: :contribution, source: :project
  has_one :matcher, through: :contribution, source: :matcher
  has_one :trip, through: :contribution, source: :trip
  scope :paid, -> { where(status: ['CLEARED', 'COMPLETED', 'PAID']) }
  scope :need_matching, -> { where(matched: 'pending') }
  scope :matched, -> { where('matched ILIKE ?', '%times-%') }
  validates :provider, presence: true
  after_save :tell_matcher

  def paypal_key
    if provider == 'paypal'
      response['payKey']
    end
  end

  # def amount
  #   if provider == 'paypal'
  #     payload['receiverList']['receiver'][0]['amount']
  #   end
  # end
  #
  # def currency
  #   if provider == 'paypal'
  #     payload['currencyCode']
  #   end
  # end
  #
  # def completed?
  #   if status == 'COMPLETED'
  #     true
  #   else
  #     false
  #   end
  # end

  def check
    # Build request object
    payment_details = paypal_api.build_payment_details({
      payKey: paypal_key
    })

    # Make API call & get response
    response = paypal_api.payment_details(payment_details)

    # Access response
    if response.success?
      status = response.status
      case status
        when 'ERROR', 'REVERSALERROR', 'CREATED', 'EXPIRED', 'CANCELED', 'REVERSED', 'DENIED', 'FAILED', 'PARTIALLY REFUNDED', 'REFUNDED', 'REFUSED', 'RETURNED', 'UNCLAIMED'
          self.status = 'aborted'
          self
        when 'HELD', 'IN PROGRESS', 'ON HOLD', 'PENDING VERIFICATION', 'PLACED', 'PROCESSING', 'REMOVED', 'TEMPORARY HOLD'
          # TO DO handle this?
          logger.warning status
          self
        when 'CLEARED', 'COMPLETED', 'PAID'
          if self.contribution.matcher
            matched = 'pending'
          else
            matched = 'n/a'
          end

          if self.update(status: status, matched: matched)
            self
          else
            logger.error self.errors.full_messages
          end
        else
          logger.error status
      end
    else
      logger.error response.error[0].message
    end
  end

  def tell_matcher
    if self.matcher && self.contribution.budget
      self.matcher.check_budget(self.contribution.budget)
    end
  end
end
