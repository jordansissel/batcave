require "clamp"
require "batcave/namespace"

class BatCave::Command::Update < Clamp::Command
  def execute
    p :Updating
  end
end
