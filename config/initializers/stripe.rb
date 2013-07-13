Stripe.api_key = "sk_test_H16ZPQUpRLDZZcGsvQbZao2g"
STRIPE_PUBLIC_KEY = "pk_test_hNltPbfQGTFuyleT8Rw5W8R5"

StripeEvent.setup do
  subscribe 'customer.subscription.deleted' do |event|
    user = User.find_by_customer_id(event.data.object.customer)
    user.expire
  end
  subscribe 'customer.subscription.updated' do |event|
    user = User.find_by_customer_id(event.data.object.customer)
    user.updated
  end
  subscribe 'customer.deleted' do |event|
    user = User.find_by_customer_id(event.data.object.customer)
    user.deleted
  end
end
  