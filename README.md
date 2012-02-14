# batcave

Wikipedia on "Batcave" uses:

> Upon his initial foray into crime-fighting, Wayne used the caves as a sanctum
> and to store his then-minimal equipment. As time went on, Wayne found the place
> ideal to create a stronghold for his war against crime, and has incorporated a
> plethora of equipment as well as expanding the cave for specific uses.

Frankly, I write a lot of code in a lot of languages. There's a lot of
boilerplate, tools, and scripts I copy from project to project. Debugging,
coding, documentation, tests, etc all are quite similar in goal across projects
but differ wildly in implementation. I'd like to codify most of this so that,
when switching between projects, the cost of context switching isn't as painful.

Essentially, I do roughly the same activities regardless of platform or language.
This project is an experiment in solving the above problem.

Ideally it'd be sweet if this project would also manage my workstation as well
as my projects. Dotfiles, packages, etc. I'm tired of setting this shit up or
scripting it sideways every few months.

## Example

Maybe, for example, I'm writing an HTTP library in Ruby, and I want to:

* run whatever services I need to test this code (like a webserver)
* run tests whenever I modify the code.
* make sure all methods have docstrings (with YARD)
* have some useful debugging tools.
* generate documentation to publish online

But new projects should be easier, too:

* create a 'go' project with a layout that works well with 'goinstall'
* create a 'ruby' project with a standard layout, Gemfile, gemspec, etc. A bin
  file that uses clamp with sample flag code. A namespace file generated for
  me, etc.
* automatically create basic tests
* include tools for debugging

Release management should be easier, too. 

## Idea: boilerplate and project creation

* dk add thing

a 'thing' is a feature, boilerplate, some debug tool, metrics or testing tool, etc.

Example:

* dk add --name example go
* dk add ruby

Both of the above will generate boilerplate projects for their respective
languages. It currently uses git to find the root of your project directory
and puts files based from that location.

Boilerplates should include basic tests, etc.

## Other ideas in command-line form

* dk release - run tests, bump version, build package, run tests, tag it, publish
* dk add travis-ci - add .travis.yml file with language detection
* dk debug - run an application inside a debugger (gdb for c/c++, ruby's debugger or pry, etc)
