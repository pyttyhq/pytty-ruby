guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  watch %r{^lib\/pytty\/(?<component>client|daemon)\/cli\/(?<command>.+_command)\.rb$} do |m|
    "spec/cli/#{m[:component]}/#{m[:command]}_spec.rb"
  end

  watch %r{^spec\/cli\/(?<component>client|daemon)\/(?<command>.+_command_spec)\.rb$} do |m|
    m.instance_variable_get(:@original_value)
  end

end

guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new

  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any? { |f| helper.uses_gemspec?(f) }

  # Assume files are symlinked from somewhere
  files.each { |file| watch(helper.real_path(file)) }
end
