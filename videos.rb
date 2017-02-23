#!/usr/bin/env ruby
require "matrix"

# def score solution
#   solution.reduce(0) do |
    
#   end
# end

lines = File.readlines(ARGV[0])

num_vid, num_end, num_req, num_cache, capacity = lines.shift.strip.split.map &:to_i

cache_capacity = Array.new(num_cache, capacity)

# video sizes
sizes = lines.shift.split

dc_latencies, endpoints = (0 ... num_end).map do |i|
  dl, k = lines.shift.split.map &:to_i

  caches = Array.new(num_cache)
  
  (0 ... k).each do |c|
    id, lat = lines.shift.split.map &:to_i
    caches[id] = lat
  end
  
  { dc_lat: dl, caches: caches }
end.map(&:each_value).map(&:to_a).transpose

requests = (0 ... num_req).map do |i|
  video_id, endpoint_id, reqs = lines.shift.split.map &:to_i
  { video: video_id, endpoint: endpoint_id, reqs: reqs }
end
