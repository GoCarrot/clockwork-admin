# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'json'

require 'zk'

module Clockwork
  module Admin
    class App < ::Sinatra::Base
      register Sinatra::ConfigFile

      # default settings
      configure do
        set :event_regex, '\A[a-zA-Z0-9_.]+\z'
        set :zk_root_node, '_clockwork'
      end

      get '/' do
        erb :'index.html'
      end

      get '/events' do
        content_type :json
        Event.all(zk, settings.zk_lock_name).to_json
      end

      get '/events/:id' do
        return [403, 'invalid event ID'] unless event_regex.match(params[:id])

        event = Event.find(zk, settings.zk_lock_name, params[:id])
        return [404, 'event not found'] if event.nil?

        content_type :json
        event.to_json
      end

      post '/events/:id' do
        return [403, 'invalid event ID'] unless event_regex.match(params[:id])

        event = Event.find(zk, settings.zk_lock_name, params[:id])
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

        content_type :json
        event.to_json
      end

      helpers do
        def base_url
          @base_url ||= request.script_name.sub(/([^\/])$/, '\1/')
        end
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
        @zk ||= ::ZK.new("#{settings.zk_cluster}/#{settings.zk_root_node}")
      end
    end
  end
end
