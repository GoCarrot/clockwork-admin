module Clockwork
  module Admin
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
end
