require "rake"
require "bundler"

begin
  require "docker"
rescue LoadError
  puts "Docker lib not available. You won't be able to manage the test database without it."
end

Bundler::GemHelper.install_tasks

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

namespace :docker do
  task :db_image do
    Docker::Image.create("fromImage" => DB_DOCKER_IMAGE)
  end

  namespace :db_container do
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

    task :stop do
      container = find_db_container
      if container
        container.stop
        puts "Stopped #{container.info["id"]} (#{container.info["Names"].join(", ")})"
      end
    end

    task :reset do
      Rake::Task["docker:db_container:stop"].invoke
      Rake::Task["docker:db_container:start"].invoke
    end
  end
end

namespace :test_db do
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

task :test => "test_db:recreate" do
  ENV["RAILS_ENV"] = "test"
  cd "test-project"
  rm "Gemfile.lock"
  sh "bundle install"
  sh "bundle exec rake db:migrate"
  sh "bundle exec rspec spec"
end
