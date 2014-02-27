class Article < ActiveRecord::Base
  is_impressionable :counter_cache => true, :column_name => :impressions_count

  include AASM
  aasm do
    state :new, initial: true
    state :approved
    state :copy
    state :ready


    event :review do
      transitions from: :new, to: :approved
    end
    event :wrote do
      transitions from: :approved, to: :copy
    end
    event :finish do
      transitions from: :copy, to: :ready
    end
  end

  belongs_to :pages

  # NOTE: might need to update sizes as the design has changed.
  has_attached_file :photo, styles: {large: "500x500>", medium: "300x300#", thumb: "100x100#" }
  validates :page, :title, :body, :author_name, presence: true
  validates :title, uniqueness: true
  has_many :comments, dependent: :destroy

  scope :published, -> { where(published: true) }

  def self.search(search)
    if search
      q = "%#{search}%"
      where("author_name LIKE ? OR title LIKE ?", q, q)
    else
      where(published: true)
    end
  end

  def page_name
    if self.page
      Page.find(self.page).name
    else
      return self.page
    end
  end
  def read_time
    # approximate cuz we don't strip html tags from the body
    # read time in minutes is word count / 150 (average words per minute for a non-dyslexic college student)
    read_time = (self.body.split.count / 150)
    if read_time > 1.0
      return (read_time.to_s + " minutes to read")
    else
      return "less than a minute to read."
    end
  end  
end
