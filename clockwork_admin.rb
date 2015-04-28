require 'json'

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/json'

module Clockwork
  # Represents the ZooKeeper state of a Clockwork event.
  class Event
    class <<self

      # Find all events belonging to a particular lock.
      def all(zk, lock_name)
        root_node = "/#{lock_name}"
        if !zk.exists? root_node
          return []
        end

        zk.children(root_node).map do |child|
          Event.new(zk, lock_name, child)
        end
      end

      # Finds a particular event.
      # Returns nil if it doesn't exist.
      def find(zk, lock_name, child)
        child_node = "/#{lock_name}/#{child}"
        puts child_node
        if !zk.exists? child_node
          return nil
        end

        return Event.new(zk, lock_name, child)
      end
    end

    def initialize(zk, root_node, child_node)
      @zk = zk
      @event_name = child_node
      @node = "/#{root_node}/#{child_node}"
      @paused_node = "#{@node}/paused"

      @dirty = false
    end

    # If the event is paused or not.
    def paused
      @paused ||= !!@zk.exists?(@paused_node)
    end

    def paused=(v)
      @dirty = true
      @paused = !!v
    end

    # The last time the event was triggered.
    def last
      @last ||= (Time.at(@zk.get(@node)[0].to_i))
    end

    # writes the paused state of the 
    def save!
      if @dirty
        if @paused
          @zk.create(@paused_node, 'T', :ignore => :node_exists)
        else
          @zk.delete(@paused_node, :ignore => :no_node)
        end

        @dirty = false
      end

      true
    end

    def to_json(state = nil)
      JSON.generate({
        event_name: @event_name,
        paused: paused,
        last: last.to_s
      })
    end
  end
end

class ClockworkAdmin < Sinatra::Base
  register Sinatra::ConfigFile
  register Sinatra::Index

  use_static_index 'index.html'

  # default settings
  configure do
    set :event_regex, '\A[a-zA-Z0-9_.]+\z'
    set :zk_root_node, '_clockwork'
  end

  config_file 'config/config.yml'

  get '/events' do
    json Clockwork::Event.all(zk, settings.zk_lock_name)
  end

  get '/events/:id' do 
    return [503, 'invalid event ID'] unless event_regex.match(params[:id])

    event = Clockwork::Event.find(zk, settings.zk_lock_name, params[:id])
    return [404, 'event not found'] if event.nil?

    json event
  end

  post '/events/:id' do
    return [503, 'invalid event ID'] unless event_regex.match(params[:id])

    event = Clockwork::Event.find(zk, settings.zk_lock_name, params[:id])
    return [404, 'event not found'] if event.nil?

    request.body.rewind
    hash = JSON.parse(request.body.read)

    case hash['paused']
    when true
      event.paused = true
    when false
      event.paused = false
    end

    event.save!

    json event
  end

  after do
    if @zk
      @zk.close
    end
  end

  private
  def event_regex
    @event_regex ||= Regexp.new(settings.event_regex)
  end

  def zk
    @zk ||= ZK.new("#{settings.zk_cluster}/#{settings.zk_root_node}")
  end
end

