require 'bundler/setup'

bundler_installed = !!(%x[gem list] =~ /bundler/)
rabbit_installed = !!(%x[rabbitmqctl status] =~ /Status of node/)

desc "Open a screen session"
task :screen do
  exec <<-CMD
    if [ $(screen -ls | grep Detached | wc -l) -gt 0 ]; then
      echo "Attaching to existing Screen"
      sleep 1.0
      screen -x -c screenrc
    else
      echo "Starting new Screen session"
      sleep 1.0
      screen -c screenrc
    fi
  CMD
end

desc "Open a screen session"
task :screen do
  exec <<-CMD
    if [ $(screen -ls | grep Detached | wc -l) -gt 0 ]; then
      echo "Attaching to existing Screen"
      sleep 1.0
      screen -x -c screenrc
    else
      echo "Starting new Screen session"
      sleep 1.0
      screen -c screenrc
    fi
  CMD
end

namespace :consumers do

  desc "Start Flopsy test consumers"
  task :start, :cmd do |t, args|
    num = args.cmd
    puts "== starting test consumer #{num}..."
    system("ruby spec/fanout_consumer.rb #{num}")
  end
  
end

desc "Start Flopsy logger"
task :flopsy_logger do
  sh "tail -f log/flopsy.log"
end

desc "Start Rabbitmq server"
task :rabbitmq do
  sh "rabbitmq-server"
end

desc "Run AMQP 0-8 rspec tests"
task :spec08 do
	require 'spec/rake/spectask'
	puts "===== Running 0-8 tests ====="
	Spec::Rake::SpecTask.new("spec08") do |t|
		t.spec_files = FileList["spec/spec_08/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

desc "Run AMQP 0-9 rspec tests"
task :spec09 do
	require 'spec/rake/spectask'
	puts "===== Running 0-9 tests ====="
	Spec::Rake::SpecTask.new("spec09") do |t|
		t.spec_files = FileList["spec/spec_09/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

task :default => [ :spec08 ]

desc "Run all rspec tests"
task :all => [:spec08, :spec09]
