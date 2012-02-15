require "clamp"
require "batcave/namespace"
require "batcave/command/add"

class BatCave::Command::Update < Clamp::Command
  parameter "ENVIRONMENT", "The environment to update (user, project, etc)",
    :attribute_name => :environment

  def execute
    store = BatCave::Store.new
    store.each(@environment) do |thing, settings|
      args = settings["args"]
      BatCave::Action::Add.new(thing, args).execute
    end
  end
end
