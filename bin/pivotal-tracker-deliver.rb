#!/usr/bin/env ruby

require 'pivotal-tracker'

PivotalTracker::Client.token = ENV["PIVOTAL_TRACKER_TOKEN"]
PivotalTracker::Client.use_ssl = true

project = PivotalTracker::Project.find(ENV["PIVOTAL_TRACKER_PROJECT_ID"])
stories = project.stories.all(:state => "finished", :story_type => ['bug', 'feature'])

stories.each do | story |
  puts "Searching for #{story.id} in local git repo."
  search_result = `git log --grep 'Finishes ##{story.id}'`
  if search_result.length > 0
    puts "Found #{story.id}, marking as delivered."
    story.notes.create(:text => "Delivered by jenkins.")
    story.update({"current_state" => "delivered"})
  else
    puts "Could not find #{story.id} in git repo."
  end
end
