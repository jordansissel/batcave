require "batcave/namespace"
require "batcave/support/git"
require "batcave/support/envpath"
require "yaml"
require "fileutils"

class BatCave::Store
  include BatCave::Support::Git
  include BatCave::Support::EnvPath

  def lock(path, &block)
    lockfile = "#{path}.lock"
    File.open(lockfile, "a+") do |lockfd|
      locked = lockfd.flock(File::LOCK_EX | File::LOCK_NB)
      if !locked
        info = lockfd.read
        raise "Store is currently locked, cannot write to it. (info: #{info})"
      end
      lockfd.rewind
      lockfd.write("pid:$$")
      lockfd.flush
      
      block.call
    end

    # This step is not required for flock(2) to work, but it should help to
    # keep users from being confused.
    File.delete(lockfile)
  end # def lock

  def store(dsl)
    basedir = path(dsl.environment)
    manifest_path = File.join(basedir, ".batcave", "manifest")
    FileUtils.mkdir_p(File.join(basedir, ".batcave"))

    lock(manifest_path) do
      manifest = load(manifest_path)
      # Store this thing.
      manifest["things"][dsl.thing] = dsl.to_hash

      # Write the manifest to a tmpfile and rename it.
      tmpfile = manifest_path + ".tmp"
      File.open(tmpfile, "w") do |tmp|
        tmp.write(manifest.to_yaml)
        tmp.flush
      end
      File.rename(tmpfile, manifest_path)
    end
  end # def store

  def each(environment, &block)
    basedir = path(environment)
    manifest_path = File.join(basedir, ".batcave", "manifest")
    manifest = load(manifest_path)
    manifest["things"].each do |thing|
      yield thing
    end
  end # def each

  def load(manifest_path)
    manifest = {}
    if File.exists?(manifest_path)
      fd = File.new(manifest_path, "a+")
      # Load the current manifest so we can modify it
      manifest = YAML.load(fd.read)
      manifest = {} if !manifest
      fd.close
    end

    # Handle empty manifest. (YAML.load returns false for empty files)
    manifest["things"] ||= {}
    return manifest
  end # def manifest
end # class BatCave::Store
