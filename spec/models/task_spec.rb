# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  description :text
#  due_date    :date
#  completed   :boolean          default(FALSE)
#  list_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  position    :integer
#  hasduedate  :boolean          default(FALSE)
#  user_id     :integer
#

require 'spec_helper'

describe Task do
  pending "add some examples to (or delete) #{__FILE__}"
end
