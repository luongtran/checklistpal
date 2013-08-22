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

class List < ActiveRecord::Base
  include CanCan::Ability
  attr_accessible :name, :user_id, :description, :slug, :completed, :last_completed_mark_at
  belongs_to :user
  has_many :tasks, :dependent => :delete_all
  has_many :list_team_members, :dependent => :delete_all # ????
  validates_uniqueness_of :slug
  validates_presence_of :name
  validates_length_of :name, :within => 3..50
  # remove laster
  def finished?
    return false if self.tasks.count == 0
    self.tasks.each do |task|
      if !task.completed
        return false
      end
    end
    return true
  end

  def actived_members
    self.list_team_members.where(:active => true)
  end

  def self.completed_notifier
    # Check every 15 minutes
    all.each do |l|
      # Check not owner by user
      if !l.user_id.blank? && l.tasks.count > 0
        if l.completed
          # !!! Check last mark a list to completed with last send email notify
          if l.last_sent_notify_email_at.nil? || l.last_completed_mark_at > l.last_sent_notify_email_at
            # Get all active members on the list
            members = ListTeamMember.where(list_id: l.id, active: true)
            user_ids = []
            members.each do |member| # bad code, many query !!!
              user_ids += [member.invited_id]
            end
            # add owner id
            user_ids += [l.user_id]
            users = User.where('id IN (?)', user_ids)
            users.each do |u|
              #   get link to the list
              UserMailer.list_completed(u.email, l).deliver
              l.update_attribute(:last_sent_notify_email_at, DateTime.now)
            end
          end
        end
      end
    end
  end
end
