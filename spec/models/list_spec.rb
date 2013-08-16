# == Schema Information
#
# Table name: lists
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  description               :string(255)
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  slug                      :string(255)
#  last_completed_mark_at    :datetime
#  last_sent_notify_email_at :datetime
#

require 'spec_helper'

describe List do
  pending "add some examples to (or delete) #{__FILE__}"
end
