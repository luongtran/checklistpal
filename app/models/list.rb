class List < ActiveRecord::Base
  include CanCan::Ability
  attr_accessible :name, :user_id, :description, :slug
  belongs_to :user
  has_many :tasks, :dependent => :delete_all
  has_many :list_team_members, :dependent => :delete_all # ????
  validates_uniqueness_of :slug
  validates_presence_of :name

  def self.completed_notifier
    # Check every 15 minutes
    puts "\n\n______________________________Completed List Checking__________________________\n"
    all.each do |l|
      # Check list complete
      if !l.user_id.blank? && l.tasks.count > 0 # not owner by user
        completed = true
        l.tasks.each do |task|
          if !task.completed
            completed = false
            break
          end
        end
        if completed # Send email to all user connect to the list
          puts "____List [#{l.id} - #{l.name}] has completed\n"
          # Get all active members on the list
          members = ListTeamMember.where(list_id: l.id, active: true)
          user_ids = []
          members.each do |member| # bad code, many query !!!
            user_ids += [member.invited_id]
          end
          user_ids += [l.user_id] # add owner id
          users = User.where('id IN (?)', user_ids)
          puts "\n____will send : #{users.count} emails"
          users.each do |u|
            #   get link to the list
            UserMailer.list_completed(u.email).deliver
            puts "____sent to #{u.email}"
          end
              # assign the list had notified
        end

      end
    end
  end
end
