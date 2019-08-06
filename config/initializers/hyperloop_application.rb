# module Hyperloop
#   class Hyperloop::Application
#     # RequestParams[:xyz] works like request.params[:xyz] on the controller

#     # We will use prerender_footer from the IsomorphicHelpers module to
#     # save the request.params as json string.
#     # Note that prererender_footer runs even if prerendering is turned off.
#     def self.request_params
#       @request_params || {}
#     end

#     def self.request_params=new_request_params
#       @request_params = new_request_params
#     end

#     include React::IsomorphicHelpers
#     prerender_footer do |controller|
#       puts "FOOTER!!! #{controller.request.params.inspect}"
#       # This block will be called as the page view is being generated.  Whatever is returned is
#       # inserted into the pages output stream.
#       "<script type='text/javascript'>\n"\
#         "window.HyperloopRequestParams = '#{controller.request.params.to_json}';\n"\
#       "</script>\n"
#       self.request_params = controller.request.params
#     end if RUBY_ENGINE != 'opal'

#    # def self.request_params
#    #    # convert back to a Opal object...
#    #    self.params ||= JSON.parse(`window.HyperloopRequestParams` || '{}')
#    #    self.params
#    #  end
#   end
# end