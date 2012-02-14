require "batcave/namespace"

module BatCave::Support::Git
  def project_root
    root = %x{git rev-parse --show-toplevel}.chomp
    if $?.exitstatus != 0
      raise "'git rev-parse --show-toplevel' failed. No project root found. Is this in a git clone?"
    end
    return root
  end # def project_root
end # class BatCave::Support::Git
