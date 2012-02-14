require "clamp"
require "batcave/namespace"
require "batcave/command/add"
require "batcave/command/update"

class BatCave::Main < Clamp::Command
  # Add something to your bat cave. 
  subcommand "add", "Add something to your batcave", BatCave::Command::Add

  # Update the batcave from upstream. This will keep you updated with
  # the latest in gadgets and useful tools.
  subcommand "update", "Update the things in your bat cave.", BatCave::Command::Update
end