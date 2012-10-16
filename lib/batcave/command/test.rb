require "clamp"
require "batcave/namespace"

class BatCave::Command::Test < Clamp::Command
  parameter "FILES ...", "Files to test", :attribute_name => :files

  private

  def gitroot(dir=Dir.pwd)
    Dir.chdir(dir) do
      return `git rev-parse --show-toplevel 2> /dev/null`.split("\n").first
    end
  end # def root

  def execute
    # Assume all files are in the same project.
    project_root = gitroot(File.dirname(files.first)) + "/"

    relative_paths = files.collect { |a| File.realpath(a).gsub(project_root, "") }
    success = true
    Dir.chdir(project_root) do
      commands = relative_paths.collect { |p| path_test_command(p) }.select { |p| !p.nil? }
      commands.each do |command|
        system(*command)
        success &&= $?.success?
      end # commands.each
    end
    return success ? 0 : 1
  end # def execute

  def path_test_command(path)
    if path =~ /^lib\//
      # Try {spec,test}/path/to/thing.rb for lib/project/path/to/thing.rb
      with(path.gsub(/^lib\/[^\/]+\//, "spec/")) { |p| path = p if File.exists?(p) }
      with(path.gsub(/^lib\/[^\/]+\//, "test/")) { |p| path = p if File.exists?(p) }

      # Try {spec,test}/path/to/thing.rb for lib/path/to/thing.rb
      with(path.gsub(/^lib\//, "spec/")) { |p| path = p if File.exists?(p) }
      with(path.gsub(/^lib\//, "test/")) { |p| path = p if File.exists?(p) }
    end

    case path
      when /^spec\/.*\.rb$/ ; return ["rspec", path]
      when /^test\/.*\.rb$/ ; return ["ruby", path]
      when /\.rb$/ ; return [ "ruby", "-c", path]
      when /\.sh$/ ; return [ "sh", "-n", path]
      when /\.pp$/ ; return [ "puppet", "parser", "validate", path ]
      else ; logger.warn("Don't know how to test", :path => path)
    end

    return nil
  end # def tests_for_path

  def with(value, &block)
    return block.call(value)
  end # def with

  public(:execute)
end
