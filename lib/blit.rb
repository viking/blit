module Blit
  def self.repository
    @@repository ||= Git.open( Merb.root + "/repos/" + Merb.env )
  end
end
