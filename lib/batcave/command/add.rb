require "clamp"
require "batcave/namespace"
require "fileutils"

class BatCave::Command::Add < Clamp::Command
  parameter "THING", "The thing to add to your batcave", :attribute_name => :thing

  def execute
    # TODO(sissel): Move this stuff into a proper batcave library

    found = false
    [ @thing, File.join(@thing, "self") ].each do |thing|
      path = File.join(BatCave::THINGSDIR, thing)
      config = File.join(path, "THING")
      if File.exists?(config)
        found = true
        use(path)
      end
    end

    if !found
      puts "Could not find any thing '#{@thing}'"
    end
  end # def execute

  def use(dir)
    config = File.join(dir, "THING")
    paths = Dir.glob(File.join(dir, "**", "*"))
      #.collect { |p| p[dir.length + 1 .. -1] } \
      #.reject { |p| p == "/THING" }
    #boilerplate = []
    #binding.eval(File.read(config), config)

    # TODO(sissel): Find the git root.
    paths.each do |path|
      localpath = path[dir.length + 1 .. -1]
      next if localpath == "THING"

      # TODO(sissel): if this is a directory, create it.
      # TODO(sissel): if this a file, copy it.
      if File.directory?(localpath)
        FileUtils.mkdir_p(localpath)
      else
        FileUtils.mkdir_p(File.dirname(localpath))
        FileUtils.cp(path, localpath)
      end
    end
  end
end
