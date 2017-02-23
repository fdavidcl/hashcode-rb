#!/usr/bin/env ruby
require "matrix"

# def score solution
#   solution.reduce(0) do |

#   end
# end

# Lambda max for nil
@imax = ->(a) { a.each_with_index.max_by { |e, i| e.nil? ? 0 : e } }

def deparse solution
  used = solution.reject(&:empty?)
  lines = used.each_with_index.map { |a, i| "#{i} #{a.join " "}" }
  "#{used.length}\n#{lines.join "\n"}"
end

lines = File.readlines(ARGV[0])

@num_vid, @num_end, @num_req, @num_cache, @capacity = lines.shift.strip.split.map &:to_i

@cache_capacity = Array.new(@num_cache, @capacity)

# video sizes
@sizes = lines.shift.split.map &:to_i

@dc_latencies, @endpoints = (0 ... @num_end).map do |i|
  dl, k = lines.shift.split.map &:to_i

  caches = Array.new(@num_cache)

  (0 ... k).each do |c|
    id, lat = lines.shift.split.map &:to_i
    caches[id] = lat
  end

  { dc_lat: dl, caches: caches }
end.map(&:each_value).map(&:to_a).transpose

@gain = (0 ... @endpoints.length).map do |i|
  @endpoints[i].map do |e|
    begin
      @dc_latencies[i] - e
    rescue
      nil
    end
  end
end

@requests = (0 ... @num_req).map do |i|
  video_id, endpoint_id, reqs = lines.shift.split.map &:to_i
  { video: video_id, endpoint: endpoint_id, reqs: reqs }
end

@arequests = @requests.map &:values

@count_caches = @endpoints.transpose.map { |e| e.reduce(0) { |ac, c| ac + (c.nil? ? 0 : 1) } }


def heuristica
  solution = Array.new(@num_cache) {Array.new}

  tam_min = @sizes.min
  cache_capacity = Array.new(@num_cache, @capacity)

  # Search max in gain, get [row, col] (endpoint, cache)

  index = @imax.(@gain.map(&@imax)).flatten[1..2].reverse

  cache_index = index.last
  avail_videos = (0...@num_vid).to_a

  while cache_capacity[cache_index] < min

  end
  puts index

end

@objective = @arequests.map do |v, e, r|
  begin
    (@dc_latencies[e] - @endpoints[e][cache]) * r / @sizes[v]
  rescue
    0
  end
end

def backpack_heuristic
  best_caches = (0 ... @num_cache).to_a.sort_by { |i| -@count_caches[i] }
  puts @count_caches.to_s
  # cache_capacity = Array.new(num_cache, capacity)

  solution = Array.new(@num_cache) { Array.new }

  best_caches.each do |cache|
    min_size = @sizes.min
    cap = @capacity
    taken = Array.new(@num_vid, false)

    puts "Cache #{cache}"
    
    until cap < min_size # que ya no quepan videos
      # 0: video, 1: endpoint, 2: requests
      nxt = @arequests.max_by do |v, e, r|
        if @sizes[v] > cap || @endpoints[e][cache].nil? || taken[v]
          0
        else
          (@dc_latencies[e] - @endpoints[e][cache]) * r / @sizes[v]
        end
      end

      break if taken[nxt[0]]
      
      #puts "#{nxt} - #{@sizes[nxt[:video]]} (rem: #{cap})"

      solution[cache] << nxt[0]
      cap -= @sizes[nxt[0]]
      taken[nxt[0]] = true
    end
  end

  solution
end

if ARGV[1] == "mochila"
  puts deparse backpack_heuristic
end

heuristica
