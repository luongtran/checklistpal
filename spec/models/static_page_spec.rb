# == Schema Information
#
# Table name: static_pages
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  content    :text
#  page_name  :string(255)
#  updated_by :string(255)
#  created_by :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe StaticPage do
  pending "add some examples to (or delete) #{__FILE__}"
end
