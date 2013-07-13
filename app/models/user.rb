class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable,  :validatable ,:omniauthable, :invitable #:trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :stripe_token, :coupon,:provider, :uid , :invitation_token,:invitation_sent_at,:invitation_accepted_at,:invitation_limit,:invited_by_id,:invited_by_type
  attr_accessor :stripe_token, :coupon, :skip_stripe_update
  before_save :update_stripe
  before_destroy :cancel_subscription
  has_many :lists
  has_many :tasks
  has_many :list_team_members
  has_many :authentications, :dependent => :destroy
  has_many :comments
  
  
  def self.list_create(user_id,list_id)
    if user = User.find(user_id)
      if user.lists.length > 0
        if !user.lists.find(:all , :conditions =>["id = ?", list_id]).empty?
          return true
        end
      else
        return false
      end
    else
      return false
    end
  end

  def update_plan(role)
    self.role_ids = []
    self.add_role(role.name)
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id)
      customer.update_subscription(:plan => role.name)
    end
    true
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to update your subscription. #{e.message}."
    false
  end
   
  def update_stripe
    return if skip_stripe_update
    return if email.include?(ENV['ADMIN_EMAIL'])
    return if email.include?('@example.com') and not Rails.env.production?    
    if customer_id.nil?
      if !stripe_token.present? && roles.first.name != 'free'
        raise "Stripe token not present. Can't create account."
      end
      if roles.first.name == 'free'
        if coupon.blank?
          customer = Stripe::Customer.create(
            :email => email,
            :description => name,
            :plan => roles.first.name
          )
        else
          customer = Stripe::Customer.create(
            :email => email,
            :description => name,
            :plan => roles.first.name,
            :coupon => coupon
          )
        end
      else
        if coupon.blank?
          customer = Stripe::Customer.create(
            :email => email,
            :description => name,
            :card => stripe_token,
            :plan => roles.first.name
          )
        else
          customer = Stripe::Customer.create(
            :email => email,
            :description => name,
            :card => stripe_token,
            :plan => roles.first.name,
            :coupon => coupon
          )
        end
      end
    else
      customer = Stripe::Customer.retrieve(customer_id)
      if stripe_token.present?
        customer.card = stripe_token
      end
      customer.email = email
      customer.description = name
      customer.save
    end
    self.last_4_digits = customer.active_card.last4 unless roles.first.name == 'free'
    self.customer_id = customer.id
    self.stripe_token = nil
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end
  
  def cancel_subscription
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id)
      unless customer.nil? or customer.respond_to?('deleted')
        if customer.subscription.status == 'active'
          customer.cancel_subscription
        end
      end
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to cancel your subscription. #{e.message}."
    false
  end
  
  def expire
    UserMailer.expire_email(self).deliver
    destroy
  end
#  Defined fod Facebook Authentication
    def apply_omniauth(omni)
    authentications.build(:provider => omni['provider'], 
      :uid => omni['uid'], 
      :token => omni['credentials'].token, 
      :token_secret => omni['credentials'].secret)
  end
  
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
    end
  end
    
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end
  
  def password_required?
    (authentications.empty? || !password.blank?) && super #&& provider.blank?
  end

  def update_with_password(params={}) 
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
      update_attributes(params) 
  end
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(  provider:auth.provider,
        uid:auth.uid,
        email:auth.info.email,
        password:Devise.friendly_token[0,20]
      )
    end
    user
  end
  
  def self.number_connect(resource)
    return resource.list_team_members.find(:all , :conditions => ["active = ? ",true]).count
  end
  
  def to_s
    email
  end
end
