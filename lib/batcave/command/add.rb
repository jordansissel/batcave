require "clamp"
require "batcave/namespace"
require "batcave/support/git"
require "fileutils"

class BatCave::Command::Add < Clamp::Command
  include BatCave::Support::Git

  option ["-n", "--name"], "NAME",
    "the application or library name", :attribute_name => :name

  parameter "THING",
    "The thing to add to your batcave", :attribute_name => :thing

  def execute
    # TODO(sissel): Move this stuff into a proper batcave library

    found = false
    # look for the 'thing/' or if it's a directory try 'thing/self/'
    [ @thing, File.join(@thing, "self") ].each do |thing|
      path = File.join(BatCave::THINGSDIR, thing)
      config = File.join(path, "THING")
      if File.exists?(config)
        found = true
        use(path)
        break
      end
    end

    if !found
      puts "Could not find any thing '#{@thing}'"
    end
  end # def execute

  def use(dir)
    config = File.join(dir, "THING")
    paths = Dir.glob(File.join(dir, "**", "*"))

    paths.each do |path|
      localpath = File.join(project_root, path[dir.length + 1 .. -1])
      next if localpath == "THING"

      if localpath.include?("{name}")
        if @name.nil?
          raise "Path requires '--name' flag to be set: #{localpath.inspect}"
        end
        localpath.gsub!("{name}", @name)
      end

      # Replace '{...}' in localpath

      # TODO(sissel): if this is a directory, create it.
      # TODO(sissel): if this a file, copy it.
      if File.directory?(path)
        FileUtils.mkdir_p(localpath) unless File.directory?(localpath)
      else
        localdir = File.dirname(localpath)
        FileUtils.mkdir_p(localdir) unless File.directory?(localdir)
        FileUtils.cp(path, localpath)
      end
    end
  end
end
