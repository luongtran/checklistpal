class Hoapi_keyokController < ApplicationController
  require 'json'

  Stripe.api_key = ENV['STRIPE_API_KEY']

  def receiver

    data_json = JSON.parse request.body.read

    p data_json['data']['object']['customer']

    if data_json[:type] == "invoice.payment_succeeded"
      make_active(data_event)
    end

    if data_json[:type] == "invoice.payment_failed"
      make_inactive(data_event)
    end
  end

  def make_active(data_event)
    @profile = Profile.find(User.find_by_stripe_customer_token(data['data']['object']['customer']).profile)
    if @profile.payment_received == false
      @profile.payment_received = true
      @profile.save!
    end
  end

  def make_inactive(data_event)
    @profile = Profile.find(User.find_by_stripe_customer_token(data['data']['object']['customer']).profile)
    if @profile.payment_received == true
      @profile.payment_received = false
      @profile.save!
    end
  end
end
