require "batcave/namespace"

module BatCave::Support::EnvPath
  def path(environment)
    case environment.to_sym
      when :user
        return ENV["HOME"]
      when :project
        return project_root
      else
        raise "Unsupported environment '#{environment}'"
    end
  end # def path
end
