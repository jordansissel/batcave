require "batcave/namespace"

class BatCave::Support::Git
  def project_root
    return %x{git rev-parse --show-toplevel}.chomp
  end # def project_root
end # class BatCave::Support::Git
