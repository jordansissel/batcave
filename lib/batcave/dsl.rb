require "batcave/namespace"
require "batcave/support/envpath"
require "fileutils"
require "cabin"

# TODO(sissel): DSL is a poor name for this class. Fix it later.
# TODO(sissel): Split the 'THING' processor from the 'Thing' instances
class BatCave::DSL
  include BatCave::Support::Git
  include BatCave::Support::EnvPath

  private

  def initialize(configfile, thing, args)
    @args = args
    @thing = thing
    @configfile = configfile
    @sourcedir = File.dirname(@configfile)
    @logger = Cabin::Channel.get("batcave")

    # Default environment is project.
    @environment = :project
    # Update all files by default
    @create_only = []

    @sync = true

    # Make this 'thing' argument into a command
    @command = Clamp::Command.new("<internal dsl thing>")
    class << @command
      def execute
        # nothing to do, we just want to parse flags.
      end
    end
    binding.eval(File.read(@configfile), @configfile)
  end # def initialize

  # Declare options for this thing. This block will be executed
  # in the context of a Clamp::Command, so anything valid in a
  # Clamp::Command definition is valid here. The options will
  # be parsed immediately after this block is evaluated.
  #
  # Example:
  #
  #     options do
  #       parameter "SOURCE", "The source to use", :attribute_name => :foo
  #     end
  def options(&block)
    @command.class.instance_eval(&block)
    @command.run(@args)

    # Copy related instance variables from the Clamp::Command to this object.
    @command.instance_variables.each do |ivar|
      # Skip ones that are part of the Command normally (not attributes)
      next if [:@invocation_path, :@context, :@remaining_arguments].include?(ivar)
      instance_variable_set(ivar, @command.instance_variable_get(ivar))
    end
  end # def options

  # Set the source to use for this thing
  def source(upstream)
    root = File.join(ENV["HOME"], ".batcave", "upstream")
    FileUtils.mkdir_p(root)
    Dir.chdir(root) do
      if !File.directory?(@thing)
        cmd = "git clone #{upstream} #{@thing}"
      else
        #cmd = "cd #{@thing}; git fetch origin master; git reset --hard origin/master"
        cmd = "cd #{@thing}; git pull origin master"
      end

      @logger.info("Running", :command => cmd)
      system(cmd)
      if $?.exitstatus != 0
        # TODO(sissel): Do something better than aborting
        raise "Command exited #{$?.exitstatus}: #{cmd}"
      end
    end
    @sourcedir = File.join(root, @thing)
  end # def source

  def target(directory)
    @target = directory
  end # def target

  # Do path expansion.
  #
  # If the path is /foo/bar/{name}
  # and @names is ["one", "two"], then this will:
  #
  # * yield "/foo/bar/one"
  # * yield "/foo/bar/two"
  #
  # A {foo} will check both @foo and @foos
  def expand(paths, &block)
    skip_re = /(^|\/)\.(\.|git|svn)/
    paths.each do |path|
      next if skip_re.match(path)
      # find all {...} in the string
      tokens = path.scan(/{[^}]+}/)
      if tokens.include?("{name}")
        names = []
        names << @name if instance_variable_defined?(:@name)
        names += @names if instance_variable_defined?(:@names)

        if names.empty?
          message = [ 
            "No {name} known, can't expand #{path}",
            "maybe add this to your THING file: ",
            "",
            "options do",
            "  parameter 'NAME', 'The {name} value', :attribute_name => :name",
            "end"
          ].join("\n")
          raise message
        end

        names.each do |name|
          yield path, path.gsub("{name}", name)
        end
      else
        yield path, path
      end
    end
  end # def expand

  def create_only(*paths)
    if paths.first.is_a?(Array)
      paths = paths.first
    end

    @create_only = paths
  end # def create_only

  # Sync two paths
  def sync
    if !instance_variable_defined?(:@sourcedir)
      @logger.error("Can't sync, no source defined")
      return
    end
    @target ||= path(@environment)

    paths = Dir.glob(File.join(@sourcedir, "**", "*"), File::FNM_DOTMATCH)
    expand(paths) do |source, target|
      next if source == @configfile # skip the 'THING' file
      originalpath = source[@sourcedir.length + 1 .. -1]
      localpath = File.join(path(@environment), target[@sourcedir.length + 1 .. -1])

      # TODO(sissel): if this is a directory, create it.
      # TODO(sissel): if this a file, copy it.
      if File.directory?(source)
        FileUtils.mkdir_p(localpath) unless File.directory?(localpath)
      else
        localdir = File.dirname(localpath)
        FileUtils.mkdir_p(localdir) unless File.directory?(localdir)

        if @create_only.include?(originalpath) and File.exists?(localpath)
          @logger.info("Skipping existing file due to 'create_only': #{localpath}")
        else 
          @logger.info("Copying", :source => source, :target => localpath)
          FileUtils.cp(source, localpath)
        end
      end
    end
  end # def sync

  # Set the environment this thing is operating in.
  #
  # Valid environments are: :system, :user, :project, :path
  #
  # This helps hint batcave update operations so you can just update your user,
  # project, etc, instead of everything at once.
  def environment(env=nil)
    if !env.nil?
      @environment = env
    end
    return @environment
  end # def environment

  def thing
    return @thing
  end # def thing

  def to_hash
    return {
      "args" => @args
    }
  end # def to_yaml

  def execute
    sync if @sync
  end

  def nosync
    @sync = false
  end # def nosync

  public(:initialize, :execute, :environment, :thing, :to_hash)
end # class BatCave::DSL
