Gem::Specification.new do |spec|
  spec.name = 'rflak'
  spec.version = '0.3'
  spec.author = 'Sebastian Nowak'
  spec.email = 'sebastian.nowak@gmail.com'
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'Simple wraper for http://flaker.pl API'
  spec.files = ["lib/flaker.rb", "lib/comment.rb", "lib/not_authorized.rb", "lib/rflak.rb", 
    "lib/traker.rb", "lib/entry.rb", "lib/user.rb", "test/entry_test.rb", "test/comment_test.rb", 
    "test/user_test.rb", "test/traker_test.rb", "test/flaker_test.rb", "lib/dummy_entry.rb"
  ]
  spec.require_path = 'lib'
  spec.extra_rdoc_files = ["README"]
  spec.add_dependency('httparty')
  spec.description = <<-E
Simple Ruby wrapper for Flaker service. Flaker is service collecting your network activities.
For more details go to http://flaker.pl
  E
 spec.homepage = "http://github.com/seban/rflak/tree/master"
end
