#!/usr/bin/env ruby
require "matrix"

# def score solution
#   solution.reduce(0) do |

#   end
# end

# Lambda max for nil
imax = ->(a) { a.each_with_index.max_by { |e, i| e.nil? ? 0 : e } }

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

gain = (0 ... endpoints.length).map do |i|
  endpoints[i].map do |e|
    begin
      e - dc_latencies[i]
    rescue
      nil
    end
  end
end

requests = (0 ... num_req).map do |i|
  video_id, endpoint_id, reqs = lines.shift.split.map &:to_i
  { video: video_id, endpoint: endpoint_id, reqs: reqs }
end

count_caches = endpoints.transpose.map { |e| e.reduce(0) { |ac, c| ac + (c.nil? ? 0 : 1) } }


def heuristica
  solution = Array.new(num_cache) {Array.new}

  tam_min = sizes.min
  cache_capacity = Array.new(num_cache, capacity)

  # Search max in gain, get [row, col] (endpoint, cache)
  index = imax.(gain.map(&imax)).flatten[1..2].reverse

  cache_index = index.last
  avail_videos = (0...num_vid).to_a

  while cache_capacity[cache_index] < min

  end


  puts index


end


def backpack_heuristic
  best_caches = (0 ... @num_cache).to_a.sort_by { |i| -count_caches[i] }
  # cache_capacity = Array.new(num_cache, capacity)

  solution = Array.new(num_cache) { Array.new }

  best_cache.each do |cache|
    min_size = sizes.max
    cap = capacity

    until cap < min_size # que ya no quepan videos
      nxt = requests.max_by do |h|
        if sizes[h[:video]] > cap
          0
        else
          (dc_latencies[h[:endpoint]] - endpoints[h[:endpoint]][cache]) * h[:reqs] / sizes[h[:video]]
        end
      end

      solution[cache] << nxt[:video]
      cap -= sizes[nxt[:video]]
    end
  end

  solution
end

if ARGV[1] == "mochila"
  puts backpack_heuristic.to_s
end

heuristica
