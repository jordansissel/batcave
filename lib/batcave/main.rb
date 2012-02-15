require "clamp"
require "batcave/namespace"
require "batcave/command/add"
require "batcave/command/update"
require "cabin"

class BatCave::Main < Clamp::Command
  option ["-v", "--verbose"], :flag, "enable verbose logging" do
    require "logger"
    logger = Cabin::Channel.get("batcave")
    p Cabin::Channel.get("batcave").object_id
    p Cabin::Channel.get("batcave").object_id
    p Cabin::Channel.get("batcave").object_id
    logger.subscribe(Logger.new(STDOUT))
    logger.level = :info
  end

  # Add something to your bat cave. 
  subcommand "add", "Add something to your batcave", BatCave::Command::Add

  # Update the batcave from upstream. This will keep you updated with
  # the latest in gadgets and useful tools.
  subcommand "update", "Update the things in your bat cave.", BatCave::Command::Update
end
