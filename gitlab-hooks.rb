require 'rubygems'
require 'sinatra'
require 'eventmachine'
require 'json'
require 'asana'
require './env' if File.exists?('env.rb')
require './env-local' if File.exists?('env-local.rb')

set :protection, :except => [:http_origin]

post '/' do
  EventMachine.run do
    json_string = request.body.read.to_s
    puts json_string
    payload = JSON.parse(json_string)

    user = payload['user_name']
    branch = payload['ref'].split('/').last

    rep = payload['repository']['name']
    push_msg = "for " + user + ":\n\nIn " + rep + " " + branch

    Asana.configure do |client|
      client.api_key = ENV['asana_token']
    end

    EventMachine.defer do
      payload['commits'].each do |commit|
        sha1 = commit['id'][0..6]
        check_commit(commit['message'], push_msg + " " + sha1 + "\n[" + commit['url'] + "]\n\n" + commit['message'])
      end
    end
  end
end

def check_commit(message, push_msg)
  task_list = []
  close_list = []

  message.split("\n").each do |line|
    task_list.concat(line.scan(/#(\d+)/)) # look for a task ID
    close_list.concat(line.scan(/(fix\w*)\W*#(\d+)/i)) # look for a word starting with 'fix' followed by a task ID
  end

  # post commit to every taskid found
  task_list.each do |taskid|
    task = Asana::Task.find(taskid[0])
    task.create_story({'text' => "#{push_msg}"})
  end

  # close all tasks that had 'fix(ed/es/ing) #:id' in them
  close_list.each do |taskid|
    task = Asana::Task.find(taskid.last)
    task.modify(:completed => true)
  end
end
