class List < ActiveRecord::Base
  include CanCan::Ability
  attr_accessible :name, :user_id, :description, :slug
  belongs_to :user
  has_many :tasks, :dependent => :delete_all
  has_many :list_team_members, :dependent => :delete_all # ????
  validates_uniqueness_of :slug
  validates_presence_of :name

  def finished?
    self.tasks.each do |task|
      if !task.completed
        return false
      end
    end
    return true
  end

  def self.completed_notifier
    # Check every 15 minutes
    puts "\n\n______________________________Completed List Checking__________________________\n"
    all.each do |l|
      # Check not owner by user
      if !l.user_id.blank? && l.tasks.count > 0
        if l.finished?
          # !!! Check last mark a list to finished with last send email notify
          if l.last_sent_notify_email_at.nil? || l.last_completed_mark_at > l.last_sent_notify_email_at

            if  l.last_completed_mark_at > l.last_sent_notify_email_at
              puts "____List has changed\n"
            end
            puts "____List [#{l.id} - #{l.name}] has completed\n"
            # Get all active members on the list
            members = ListTeamMember.where(list_id: l.id, active: true)
            user_ids = []
            members.each do |member| # bad code, many query !!!
              user_ids += [member.invited_id]
            end
            # Add owner id
            user_ids += [l.user_id]
            users = User.where('id IN (?)', user_ids)
            puts "\n____will send : #{users.count} emails"
            users.each do |u|
              #   get link to the list
              UserMailer.list_completed(u.email).deliver
              puts "____sent to #{u.email}"
              l.update_attribute(:last_sent_notify_email_at, DateTime.now)
            end

          end

        end

      end
    end
  end
end
