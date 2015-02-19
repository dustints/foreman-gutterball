module ForemanGutterball
  class GutterballService < ::Katello::HttpResource
    def initialize
      cfg = SETTINGS.with_indifferent_access
      url = cfg['foreman_gutterball']['url']
      @uri = URI.parse(url)
      self.prefix = @uri.path
      self.site = "#{@uri.scheme}://#{@uri.host}:#{@uri.port}"
      self.class.site = site
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

    def hash_to_query(query_parameters)
      query_parameters.reduce('?') do |result, (current_key, current_value) |
        result << '&' unless result == '?'
        if current_value.is_a?(Array)
          result << current_value.map { |value| "#{current_key}=#{self.class.url_encode(value)}" }.join('&')
        else
          result << "#{current_key}=#{self.class.url_encode(current_value)}"
        end
      end
    end

    def report(report_key, query_params)
      format_query(query_params)
      path = self.class.join_path(prefix, 'reports', report_key, 'run', hash_to_query(query_params))
      # might need a SAX parser after looking at all that data
      raw = self.class.get(path, default_headers)
      resp = JSON.parse(raw)
      send("format_#{report_key}_response", resp) # REFLECTION!!!11!1
    end

    private

    def format_query(params)
      if params[:system_id]
        params[:consumer_uuid] = params.delete(:system_id)
      end

      params[:custom_results] = 1
    end

    def format_consumer_status_response(response)
      # do all your crazy shit here
      ::ForemanGutterball::Formatters::ReportFormatter.new.flatten(
        ::ForemanGutterball::Formatters::ReportFormatter.new.format(response))
    end

    def format_consumer_trend_response(response)
      ::ForemanGutterball::Formatters::ReportFormatter.new.flatten(
        ::ForemanGutterball::Formatters::ReportFormatter.new.format(response))
    end

    def format_status_trend_response(response)
      response = ::ForemanGutterball::Formatters::ReportFormatter.new.serialize(response)
      response.map do |status|
        timestamp = status[0]
        { 'timestamp' => timestamp }.merge(status[1])
      end
    end
  end
end
