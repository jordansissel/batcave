Gem::Specification.new do |spec|
  files = %x{git ls-files}.split("\n")

  spec.name = "batcave"
  spec.version = "0.0.1"
  spec.summary = "Experiments in tools, boilerplatery, debugging, etc."
  spec.summary = spec.description
  spec.add_dependency("clamp")
  spec.files = files
  spec.bindir = "bin"
  spec.executables << "dk"

  spec.author = "Jordan Sissel"
  spec.email = "jls@semicomplete.com"
  spec.homepage = "https://github.com/jordansissel/batcave"
end

