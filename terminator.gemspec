## terminator.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "terminator"
  spec.version = "1.0.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "terminator"
  spec.description = "an external timeout mechanism based on processes and signals"
  spec.license = "same as ruby's"

  spec.files =
["README",
 "README.tmpl",
 "Rakefile",
 "doc",
 "doc/classes",
 "doc/classes/Terminator",
 "doc/classes/Terminator.html",
 "doc/classes/Terminator.src",
 "doc/classes/Terminator.src/M000001.html",
 "doc/classes/Terminator/Error.html",
 "doc/created.rid",
 "doc/files",
 "doc/files/lib",
 "doc/files/lib/terminator_rb.html",
 "doc/files/samples",
 "doc/files/samples/a_rb.html",
 "doc/files/samples/b_rb.html",
 "doc/files/samples/c_rb.html",
 "doc/files/samples/d_rb.html",
 "doc/files/samples/e_rb.html",
 "doc/files/spec",
 "doc/files/spec/terminator_spec_rb.html",
 "doc/fr_class_index.html",
 "doc/fr_file_index.html",
 "doc/fr_method_index.html",
 "doc/index.html",
 "doc/rdoc-style.css",
 "gen_readme.rb",
 "lib",
 "lib/terminator.rb",
 "samples",
 "samples/a.rb",
 "samples/b.rb",
 "samples/c.rb",
 "samples/d.rb",
 "samples/e.rb",
 "spec",
 "spec/terminator_spec.rb",
 "terminator.gemspec"]

  spec.executables = []
  
  spec.require_path = "lib"

  spec.test_files = nil

  
    spec.add_dependency(*["fattr", " >= 2.2"])
  

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "https://github.com/ahoward/terminator"
end
