class NotificationsStore < Hyperloop::Store

  receives ::Notify do
    puts "received: #{params.inspect}"
    puts "acting_user: #{CurrentUserStore.current_user.inspect}"
  end
end