require "batcave/namespace"

module BatCave::Support::Git
  def project_root
    return @project_root if instance_variable_defined?(:@project_root)
    root = %x{git rev-parse --show-toplevel}.chomp
    if $?.exitstatus != 0
      raise "'git rev-parse --show-toplevel' failed. No project root found. Is this in a git clone?"
    end
    @project_root = root
    return root
  end # def project_root
end # class BatCave::Support::Git
