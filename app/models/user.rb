class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :pages
  validates :name, uniqueness: true # make sure name is unique
  before_create :setup_role
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100#", :icon => "50X50#" }, :default_url => "blank_profile.png"
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def page_name
    if self.page
      Page.find(self.page).name
    else
      return ""
    end
  end

  def role?(role)
    return !!self.roles.find_by_name(role.to_s)
  end
  private
  def setup_role
    if self.role_ids.empty?
      self.role_ids = [3] #
    end
  end
end
