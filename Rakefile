require "rake"
require "bundler"

begin
  require "docker"
rescue LoadError
  puts "Docker lib not available. You won't be able to manage the test database without it."
end

namespace "bundler" do
  Bundler::GemHelper.install_tasks
end

DB_DOCKER_IMAGE = "percona:5.6"
DB_PORT = 3307
DB_PASSWORD = ENV["SEC_DB_PASSWORD"]

def find_db_container
  Docker::Container.all.find { |c| c.info["Image"] == DB_DOCKER_IMAGE }
end

def run_command(cmd)
  puts cmd
  result = system(cmd)
  if !result
    cmd_arg = cmd.split(" ").first
    STDERR.puts("#{cmd_arg} failed. Exit status: #{$?.inspect}")
    raise "command #{cmd_arg} failed"
  end
end

# A subclass of Bundler::GemHelper that allows us to push to Gemfury
# instead of rubygems.org.
class GemfuryGemHelper < Bundler::GemHelper
  def release_gem(built_gem_path=nil)
    guard_clean
    built_gem_path ||= build_gem
    tag_version { git_push } unless already_tagged?
    gemfury_push(built_gem_path) if gem_push?
  end

  protected

  def gemfury_push(path)
    sh("fury push --as=reverbnation '#{path}'")
    Bundler.ui.confirm "Pushed #{name} #{version} to gemfury.com."
  end
end

spec = Bundler::GemHelper.gemspec

task :default => :test

namespace :docker do
  desc "Pull the database image (#{DB_DOCKER_IMAGE}) to the docker server."
  task :db_image do
    Docker::Image.create("fromImage" => DB_DOCKER_IMAGE)
  end

  namespace :db_container do
    desc "Start the test database container."
    task :start do
      container = find_db_container
      if container.nil?
        container = Docker::Container.create({
            "Image" => DB_DOCKER_IMAGE,
            "Env" => [
              "MYSQL_ROOT_PASSWORD=#{DB_PASSWORD}",
            ],
            "PortBindings" => {
              "3306/tcp" => [
                { "HostPort" => DB_PORT.to_s }
              ]
            }
          })
        container.refresh!
        puts "Created container #{container.info["id"]} (#{container.info["Names"].join(", ")})"
        container.start
        puts "Started container #{container.info["id"]} (#{container.info["Names"].join(", ")})"
        sleep(10)
      else
        puts "Container running as #{container.info["id"]} (#{container.info["Names"].join(", ")})"
      end
    end

    desc "Stop the test database container."
    task :stop do
      container = find_db_container
      if container
        container.stop
        puts "Stopped #{container.info["id"]} (#{container.info["Names"].join(", ")})"
      end
    end

    desc "Restart the test database container."
    task :reset do
      Rake::Task["docker:db_container:stop"].invoke
      Rake::Task["docker:db_container:start"].invoke
    end
  end
end

namespace :test_db do
  desc "Rebuild the test database."
  task :recreate => "docker:db_container:start" do
    docker_host = ENV["DOCKER_HOST"] =~ /tcp:\/\/(.*):\d+/ && $1
    create_database_sql = File.expand_path("../test-project/db/create_databases.sql", __FILE__)
    run_command("mysql -v -h #{docker_host} -P #{DB_PORT} -u root --password=#{DB_PASSWORD} < #{create_database_sql}")

    sharding_sql = File.expand_path("../test-project/db/sharding.sql", __FILE__)
    run_command("mysql -v -h #{docker_host} -P #{DB_PORT} -u root --password=#{DB_PASSWORD} -D db_charmer_sandbox_test < #{sharding_sql}")

    sql = <<-_SQL
      SET PASSWORD FOR 'db_charmer_ro'@'%' = PASSWORD('#{DB_PASSWORD}')
    _SQL
    File.open("set_password.sql", "wb") { |f| f.write(sql) }
    run_command("mysql -v -h #{docker_host} -P #{DB_PORT} -u root --password=#{DB_PASSWORD} < set_password.sql")
    rm("set_password.sql")
  end
end

desc "Start the test database container, and run the test suite against it."
task :test => "test_db:recreate" do
  ENV["RAILS_ENV"] = "test"
  cd "test-project"
  rm_f "Gemfile.lock"
  sh "bundle install"
  sh "bundle exec rake db:migrate"
  sh "bundle exec rspec spec"
end

desc "Build #{spec.name}-#{spec.version}.gem into the pkg directory."
task :build => "bundler:build"

desc "Create tag v#{spec.version} and build and push #{spec.name}-#{spec.version}.gem to Gemfury"
task :release => "bundler:build" do
  GemfuryGemHelper.new.release_gem
end
