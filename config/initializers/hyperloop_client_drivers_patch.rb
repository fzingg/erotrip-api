# # RUNS ON 1.0.0-lap9, NOTHING CHANGED SINCE 0.5.8

# #### this is going to need some refactoring so that HyperMesh can add its methods in here...

# module Hyperloop
#   # Client side handling of synchronization messages
#   # When a synchronization message comes in, the client will sync_dispatch
#   # We use ERB to determine the configuration and implement the appropriate
#   # client interface to sync_change or sync_destroy

#   class Application
#     def self.acting_user_id
#       ClientDrivers.opts[:acting_user_id]
#     end
#   end


#   def self.disconnect(*channels)
#     channels.each do |channel|
#       if channel.is_a? Class
#         IncomingBroadcast.disconnect_from(channel.name)
#       elsif channel.is_a?(String) || channel.is_a?(Array)
#         IncomingBroadcast.disconnect_from(*channel)
#       elsif channel.id
#         IncomingBroadcast.disconnect_from(channel.class.name, channel.id)
#       else
#         raise "cannot connect to model before it has been saved"
#       end
#     end
#   end

#   class IncomingBroadcast

#     def self.remove_connection(channel_name, id = nil)
#       channel_string = "#{channel_name}#{'-'+id.to_s if id}"
#       open_channels.delete channel_string
#       channel_string
#     end

#     def self.disconnect_from(channel_name, id = nil)
#       channel_string = remove_connection(channel_name, id)
#       if ClientDrivers.opts[:transport] == :pusher
#         channel = "#{ClientDrivers.opts[:channel]}-#{channel_string}"
#         %x{
#           var channel = #{ClientDrivers.opts[:pusher_api]}.unsubscribe(#{channel.gsub('::', '==')});
#         }
#       elsif ClientDrivers.opts[:transport] == :action_cable
#         channel = "#{ClientDrivers.opts[:channel]}-#{channel_string}"
#         %x{
#           var foundChannel = #{Hyperloop.action_cable_consumer}.subscriptions.subscriptions.find( function(e) {
#             return JSON.parse(e.identifier).hyperloop_channel == #{channel_string}
#           } );
#           if (foundChannel) { #{Hyperloop.action_cable_consumer}.subscriptions.remove(foundChannel); }
#         }
#       else
#         HTTP.get(ClientDrivers.polling_path(:unsubscribe, channel_string))
#       end
#     end
#   end

# end