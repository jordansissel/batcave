Gem::Specification.new do |spec|
  files = %x{git ls-files}.split("\n")

  spec.name = "batcave"
  spec.version = "0.0.11"
  spec.summary = "Experiments in tools, boilerplatery, debugging, etc."
  spec.description = spec.summary
  spec.add_dependency("clamp")
  spec.add_dependency("cabin")
  spec.files = files
  spec.bindir = "bin"
  spec.executables << "dk"

  spec.add_dependency("stud", ">= 0.0.14")
  spec.add_dependency("octokit")
  spec.author = "Jordan Sissel"
  spec.email = "jls@semicomplete.com"
  spec.homepage = "https://github.com/jordansissel/batcave"
end

