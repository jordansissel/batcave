require "batcave/namespace"
require "batcave/support/git"

class BatCave::Action::Add
  include BatCave::Support::Git

  private

  # Add a new thing with some arguments.
  # 
  # Arguments for each thing are defined in the 'THING' file for each ... thing.
  def initialize(thing, args)
    @logger = Cabin::Channel.get("batcave")
    @thing = thing
    @args = args
  end # def initialize

  def find_thing(thing)
    found = false
    # look for the 'thing/' or if it's a directory try 'thing/self/'
    [ @thing, File.join(@thing, "self") ].each do |thing|
      path = File.join(BatCave::THINGSDIR, thing)
      config = File.join(path, "THING")
      return config if File.exists?(config)
    end

    puts "Could not find any thing '#{@thing}'"
    return false
  end # def find_thing

  def execute
    config = find_thing(@thing)
    dsl = BatCave::DSL.new(config, @thing, @args)
    dsl.execute

    # TODO(sissel): Record that we've added this thing.
    puts "Adding #{dsl.environment}/#{@thing}"
    store = BatCave::Store.new
    store.store(dsl)
  end # def execute

  public(:initialize, :execute)
end # class BatCave::Action::Add
