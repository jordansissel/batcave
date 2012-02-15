require "clamp"
require "batcave/namespace"
require "batcave/action/add"
require "batcave/dsl"
require "batcave/store"
require "fileutils"

# TODO(sissel): Need to track what we've added so we can sync later.

class BatCave::Command::Add < Clamp::Command

  # TODO(sissel): Move this to the 'thing' DSL
  option ["-n", "--name"], "NAME",
    "the application or library name", :attribute_name => :name

  parameter "THING",
    "The thing to add to your batcave", :attribute_name => :thing

  parameter "[THINGARGS] ...", "arguments to pass to the thing", :attribute_name => :args

  def execute
    BatCave::Action::Add.new(@thing, @args).execute
  end # def execute
end
