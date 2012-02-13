# batcave

Wikipedia on "Batcave" uses:

> Upon his initial foray into crime-fighting, Wayne used the caves as a sanctum
> and to store his then-minimal equipment. As time went on, Wayne found the place
> ideal to create a stronghold for his war against crime, and has incorporated a
> plethora of equipment as well as expanding the cave for specific uses.

As in coding, you start with some minimal tools and gradually find better
tools, better flows, etc.

This project is an experiment to try and make batcave construction possible.

Maybe, for example, I'm writing an HTTP library in Ruby, and I want to:

* run whatever services I need to test this code (like a webserver)
* run tests whenever I modify the code.
* make sure all methods have docstrings (with YARD)
* have some useful debugging tools.

But new projects should be easier:

* create a 'go' project with a layout that works well with 'goinstall'
* create a 'ruby' project with a standard layout, Gemfile, gemspec, etc
* etc.

Release management should be easier, too. 
