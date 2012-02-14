module BatCave
  module Command; end
  module Support; end # TODO(sissel): Support is a shitty namespace name.
  THINGSDIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "things"))
end
