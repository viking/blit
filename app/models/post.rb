class Post < Blit::Base
  attributes :title, :body, :permalink
  before_create :set_permalink

  def set_permalink
    self.permalink = title.gsub(/ /, '-')
  end
end
