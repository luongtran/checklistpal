# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  customer_id            :string(255)
#  last_4_digits          :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#  invitation_token       :string(60)
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#

class User < ActiveRecord::Base
  rolify
  @@AWS3_AVATARS_BUCKET = "Tudli"
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, :invitable, :trackable
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :stripe_token, :coupon, :provider, :uid, :invitation_token, :invitation_sent_at, :invitation_accepted_at, :invitation_limit, :invited_by_id, :invited_by_type,
                  :avatar_s3_url, :avatar_file_name, :avatar_url_expires_at
  attr_accessor :stripe_token, :coupon, :skip_stripe_update, :is_invited_user
  before_create :update_stripe
  after_create :send_welcome_mail
  after_destroy :cancel_subscription, :remove_on_list_team_members

  has_many :lists, :order => 'created_at desc', :dependent => :destroy #, :select => 'id,name,user_id'
  has_many :lists_id, :class_name => 'List', :select => 'id'
  has_many :tasks, :through => :lists
  has_many :list_team_members
  has_many :authentications, :dependent => :destroy
  has_many :comments, :dependent => :destroy


  #validates_presence_of :name
  #validates_length_of :name, :minimum => 3

  def update_avatar(file)
    #need remove old avatar
    filename = sanitize_filename(file.original_filename)
    s3 = AWS::S3.new
    bucket = s3.buckets.create(@@AWS3_AVATARS_BUCKET)
    obj = bucket.objects["#{self.id}-#{filename}"]
    obj.write(file.read)
    self.update_attribute(:avatar_file_name, "#{self.id}-#{filename}")
  end

  def is_facebook_account?
    if Authentication.where(user_id: self.id).count > 0
      return true
    end
    return false
  end

  def get_avatar_url
    if self.is_facebook_account?
      return avatar_s3_url
    else
      if self.avatar_file_name.nil? # never upload avatar
        return nil
      else
        s3 = AWS::S3.new
        bucket = s3.buckets.create(@@AWS3_AVATARS_BUCKET)
        obj = bucket.objects[self.avatar_file_name]
        return obj.url_for(:read).to_s
      end
    end
  rescue Exception => e
    return nil
  end

# Check user can create a new list
  def can_create_new_list?
    lists.count < roles.first.max_savedlist ? true : false
  end

  def self.list_create(user_id, list_id)
    if user = User.find(user_id)
      if user.lists.length > 0
        if !user.lists.where(id: list_id).empty?
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
    old_role = self.roles.first
    self.role_ids = []
    self.add_role(role.name)
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id)
      customer.update_subscription(:plan => role.name)
      if role.name == 'free'
        UserMailer.downgraded(self).deliver
      else
        if old_role.name == 'paid' || old_role.name == 'paid2'
          UserMailer.changeplan(self).deliver
        else # free to paid or paid2
          UserMailer.upgraded(self).deliver
        end
      end
    end
    true
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to update your subscription. #{e.message}."
    false
  end

  def update_stripe_for_invited_user
    customer = Stripe::Customer.create(
        :email => email,
        :description => name,
        :plan => roles.first.name
    )
    self.customer_id = customer.id
    save
  end

  def update_stripe
    return if is_invited_user
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
    self.last_4_digits = customer.cards.data.first["last4"] unless roles.first.name == 'free'
    # self.last_4_digits = customer.active_card.last4
    self.customer_id = customer.id
    self.stripe_token = nil
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end

  def update_credit_card
    customer = Stripe::Customer.retrieve(customer_id)
    customer.card = stripe_token
    if customer.save
      puts "\n\n___last 4 : #{customer.cards.data.first["last4"]}"
      self.last_4_digits = customer.cards.data.first["last4"]
      return true
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to updated your account: #{e.message}."
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
      # nothing
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to cancel your subscription. #{e.message}."
    false
  end

  def remove_on_list_team_members
    ListTeamMember.where(:invited_id => self.id).destroy_all
  end

  def send_invitation_email token, des_email
    UserMailer.invitations_email(self, token, des_email).deliver
  end

  def send_welcome_mail
    return if self.is_invited_user
    UserMailer.welcome_email(self) #.deliver
  end

  def expire
    UserMailer.expire_email(self).deliver
    destroy
  end

#def updated
#  UserMailer.thanks_email(self).deliver
#end
  def deleted
    UserMailer.delete_account(self).deliver
  end

  def welcome
    UserMailer.welcome_email(self).deliver
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
    params.delete(:current_password)
    update_attributes(params)
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    logger = Logger.new('log/facebook.log')
    logger.info('\n find_for_facebook_oauth function in User Model : \n')
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(provider: auth.provider,
                         uid: auth.uid,
                         email: auth.info.email,
                         name: auth,
                         password: Devise.friendly_token[0, 20]
      )
      user.add_role('free')
    end
    user
  end

# created 27/08/13
  def connection_count
    ListTeamMember.where(:user_id => self.id, active: true).select('distinct invited_id').count
  end

  def connections
    members = ListTeamMember.where(:user_id => self.id, active: true).select('distinct invited_id')
    u_ids = []
    members.each do |m|
      u_ids += [m.invited_id]
    end
    u_ids
  end

  def self.number_connect(resource)
    listconnect = resource.list_team_members.find(:all, :conditions => ["active = ? ", true])
    @user_ids = []
    listconnect.each do |list|
      @user_ids += [list.invited_id]
    end
    return User.where("id IN (?)", @user_ids).count
  end

  def self.already_connect(user, invite_user)
    if user.list_team_members.find(:first, :conditions => ["active = ? AND invited_id = ?", true, invite_user.id])
      return true
    else
      return false
    end
  end

  def self.number_free_user
    count = 0
    self.all.each do |user|
      if !user.roles.first.nil?
        if user.roles.first.name == "free"
          count += 1
        end
      end
    end
    return count
  end

  def self.number_paid_user
    count = 0
    self.all.each do |user|
      if !user.roles.first.nil?
        if user.roles.first.name == "paid"
          count += 1
        end
      end
    end
    return count
  end

  def to_s
    email
  end


  private
  def sanitize_filename(file_name)
    just_filename = File.basename(file_name)
    just_filename.sub(/[^\w\.\-]/, '_')
  end

  def avatar_uploader(filename, data)
    s3 = AWS::S3.new
    bucket = s3.buckets.create(@@AWS3_AVATARS_BUCKET)
    obj = bucket.objects[filename]
    obj.write(data)
    self.update_attribute(:avatar_file_name, filename)
  end

end
