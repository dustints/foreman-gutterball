module ForemanGutterball
  class GutterballService < ::Katello::HttpResource
    def initialize
      cfg = SETTINGS.with_indifferent_access
      url = cfg['foreman_gutterball']['url']
      @uri = URI.parse(url)
      self.prefix = @uri.path
      self.site = "#{@uri.scheme}://#{@uri.host}:#{@uri.port}"
      self.class.site = self.site
      self.consumer_secret = cfg[:oauth_consumer_secret]
      self.consumer_key = cfg[:oauth_consumer_key]
      self.ca_cert_file = cfg[:ca_cert_file]
    end

    def self.default_headers
      { 'accept' => 'application/json',
        'accept-language' => I18n.locale,
        'content-type' => 'application/json' }
    end

    def self.logger
      ::Logging.logger['gutterball_service']
    end

    def report_details(report_key)
      path = self.class.join_path(prefix, 'reports', report_key)
      JSON.parse self.class.get(path, default_headers)
    end

    def report(report_key, query_params)
      format_query(query_params)
      require 'debugger'
      debugger
      path = self.class.join_path(prefix, 'reports', report_key, 'run', self.class.hash_to_query(query_params))
      require 'debugger'
      debugger
      #might need a SAX parser after looking at all that data
      resp = JSON.parse self.class.get(path, default_headers)
      formatted_resp = ::Actions::ForemanGutterball::ContentReports::ReportFormatter.new.serialize(resp)
      send("format_#{report_key}_response", formatted_resp) # REFLECTION!!!11!1
    end

    private

    def format_query(params)
      if params[:system_id]
        params[:consumer_uuid] = params.delete(:system_id)
      end

      # params[:owner] = Organization.find(params[:organization_id]).label
      params[:owner] = 'redhat' # temporarily to test against another server
      params.delete(:organization_id)

      params[:per_page] ||= 100
      params[:custom_results] = 1
    end

    def format_consumer_status_response(response)
      # do all your crazy shit here
      response
    end

    def format_consumer_trend_response(response)
      # crazy schtuff
      response
    end

    def format_status_trend_response(response)
      # moar crazy
      response
    end
  end
end
