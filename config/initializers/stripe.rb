Stripe.api_key = ENV['STRIPE_API_KEY']
STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC_KEY']

StripeEvent.setup do
  subscribe 'customer.subscription.deleted' do |event|
    user = User.find_by_customer_id(event.data.object.customer)
    user.expire
  end
  subscribe 'customer.subscription.updated' do |event|
    user = User.find_by_customer_id(event.data.object.customer)
    role = Role.find(:first , :conditions => ["name = ?",event.data.object.plan.id])
    user.add_role(role.name)
#    if role.name == 'free'
#        UserMailer.downgraded(self).deliver
#      elsif role.name == 'paid'
#        UserMailer.upgraded(self).deliver
#      end
  end
  subscribe 'customer.deleted' do |event|
    user = User.find_by_customer_id(event.data.object.subscription.customer)
    user.deleted
  end
  subscribe 'customer.created' do |event|
    user = User.find_by_customer_id(event.data.object.subscription.customer)
    user.welcome
  end
end
  