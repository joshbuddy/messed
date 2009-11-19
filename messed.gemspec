# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{messed}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joshua Hull"]
  s.date = %q{2009-11-18}
  s.default_executable = %q{messed}
  s.description = %q{A framework for short message paradigms}
  s.email = %q{joshbuddy@gmail.com}
  s.executables = ["messed"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
     "Rakefile",
     "VERSION",
     "application_spec/Rakefile",
     "application_spec/app/runner.rb",
     "application_spec/bin/runner",
     "application_spec/bin/status",
     "application_spec/bin/web",
     "application_spec/config/application.rb",
     "application_spec/config/interfaces.yml",
     "application_spec/spec/application_spec.rb",
     "application_spec/spec/spec.opts",
     "application_spec/spec/spec_helper.rb",
     "bin/messed",
     "lib/messed.rb",
     "lib/messed/booter.rb",
     "lib/messed/controller.rb",
     "lib/messed/controller/helper.rb",
     "lib/messed/controller/processing.rb",
     "lib/messed/controller/respond.rb",
     "lib/messed/interface.rb",
     "lib/messed/interface/adapter.rb",
     "lib/messed/interface/adapter/sms.rb",
     "lib/messed/interface/adapter/twitter_search.rb",
     "lib/messed/interface/adapter/twitter_sender.rb",
     "lib/messed/interface/em_runner.rb",
     "lib/messed/interface/runner.rb",
     "lib/messed/logger.rb",
     "lib/messed/matcher.rb",
     "lib/messed/message.rb",
     "lib/messed/message/twitter.rb",
     "lib/messed/queue.rb",
     "lib/messed/queue/beanstalk.rb",
     "lib/messed/session.rb",
     "lib/messed/session/memcache.rb",
     "lib/messed/tasks.rb",
     "lib/messed/tasks/generation.rb",
     "lib/messed/tasks/runner.rb",
     "patterns/messed/Pattern",
     "patterns/messed/Rakefile",
     "patterns/messed/app/runner.rb",
     "patterns/messed/bin/runner",
     "patterns/messed/bin/status",
     "patterns/messed/bin/web",
     "patterns/messed/config/application.rb",
     "patterns/messed/config/interfaces.yml",
     "patterns/messed/spec/application_spec.rb",
     "patterns/messed/spec/spec.opts",
     "patterns/messed/spec/spec_helper.rb",
     "spec/adapter/applications/twitter_search/app/application.rb",
     "spec/adapter/applications/twitter_search/app/runner.rb",
     "spec/adapter/applications/twitter_search/bin/incoming",
     "spec/adapter/applications/twitter_search/bin/runner",
     "spec/adapter/applications/twitter_search/bin/status",
     "spec/adapter/applications/twitter_search/config/adapters.yml",
     "spec/adapter/applications/twitter_search/config/application.rb",
     "spec/adapter/applications/twitter_search/config/incoming.yml",
     "spec/adapter/applications/twitter_search/config/incoming_outgoing.yml",
     "spec/adapter/applications/twitter_search/config/interfaces.yml",
     "spec/adapter/applications/twitter_search/config/outgoing.yml",
     "spec/adapter/applications/twitter_search/config/runners.yml",
     "spec/adapter/applications/twitter_sender/app/application.rb",
     "spec/adapter/applications/twitter_sender/app/runner.rb",
     "spec/adapter/applications/twitter_sender/bin/incoming",
     "spec/adapter/applications/twitter_sender/bin/runner",
     "spec/adapter/applications/twitter_sender/bin/status",
     "spec/adapter/applications/twitter_sender/config/adapters.yml",
     "spec/adapter/applications/twitter_sender/config/application.rb",
     "spec/adapter/applications/twitter_sender/config/incoming.yml",
     "spec/adapter/applications/twitter_sender/config/incoming_outgoing.yml",
     "spec/adapter/applications/twitter_sender/config/interfaces.yml",
     "spec/adapter/applications/twitter_sender/config/outgoing.yml",
     "spec/adapter/applications/twitter_sender/config/runners.yml",
     "spec/adapter/http/direct_message",
     "spec/adapter/http/twitter_search",
     "spec/adapter/http/update",
     "spec/adapter/twitter_search_spec.rb",
     "spec/adapter/twitter_sender_spec.rb",
     "spec/application_spec.rb",
     "spec/message_spec.rb",
     "spec/session_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/joshbuddy/messed}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A framework for short message paradigms}
  s.test_files = [
    "spec/adapter/applications/twitter_search/app/application.rb",
     "spec/adapter/applications/twitter_search/app/runner.rb",
     "spec/adapter/applications/twitter_search/config/application.rb",
     "spec/adapter/applications/twitter_sender/app/application.rb",
     "spec/adapter/applications/twitter_sender/app/runner.rb",
     "spec/adapter/applications/twitter_sender/config/application.rb",
     "spec/adapter/twitter_search_spec.rb",
     "spec/adapter/twitter_sender_spec.rb",
     "spec/application_spec.rb",
     "spec/message_spec.rb",
     "spec/session_spec.rb",
     "spec/spec_helper.rb",
     "test/app/runner.rb",
     "test/config/application.rb",
     "test/spec/application_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<em-http-request>, [">= 0"])
      s.add_runtime_dependency(%q<em-beanstalk>, [">= 0"])
      s.add_runtime_dependency(%q<hashify>, [">= 0"])
      s.add_runtime_dependency(%q<methodmissing-hwia>, [">= 1.0.2"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<dressmaker>, [">= 0.0.2"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<em-http-request>, [">= 0"])
      s.add_dependency(%q<em-beanstalk>, [">= 0"])
      s.add_dependency(%q<hashify>, [">= 0"])
      s.add_dependency(%q<methodmissing-hwia>, [">= 1.0.2"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<dressmaker>, [">= 0.0.2"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<em-http-request>, [">= 0"])
    s.add_dependency(%q<em-beanstalk>, [">= 0"])
    s.add_dependency(%q<hashify>, [">= 0"])
    s.add_dependency(%q<methodmissing-hwia>, [">= 1.0.2"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<dressmaker>, [">= 0.0.2"])
  end
end

