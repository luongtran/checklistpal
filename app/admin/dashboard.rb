ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc { I18n.t("active_admin.dashboard") }

  content :title => proc { I18n.t("active_admin.dashboard") } do
    div :class => "blank_slate_container", :id => "dashboard_default_message" do
      span :class => "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
  end # content
  content :title => proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Customers" do
          table_for User.order('id desc').limit(50) do
            column("Name") { |user| status_tag(user.name,:ok) }
            column("Email") { |user| link_to(user.email, admin_user_path(user.id)) }
            column("Number of list") { |user| user.lists.count }
            column("Number of task") { |user| user.tasks.count }
          end
        end
      end
    end
  end
end
