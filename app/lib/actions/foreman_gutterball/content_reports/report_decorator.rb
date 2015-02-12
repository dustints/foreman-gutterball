module Actions
  module ForemanGutterball
    module ContentReports
      class ReportDecorator
        def decorate(report)
          if report.is_a?(Hash)
            ::Actions::ForemanGutterball::ContentReports::ReportAssociativeArrayDecorator.new(report)
          elsif report.is_a?(Array)
            ::Actions::ForemanGutterball::ContentReports::ReportArrayDecorator.new(report) 
          elsif report.is_a?(String)
            report
          elsif report.nil?
            ""
          else
            raise 'unable to decorate this report'
          end
        end

        #primative output rather than serilization
        def serialize(report)
          JSON.parse(decorate(report).to_json)
        end
      end

      class ReportAssociativeArrayDecorator
        def initialize(report)
          @report = report
        end

        def key_translation_mapping
          result = {}
          @report.keys.each{|key| result[key] = KatelloToCandlepinTranslator.new.to_katello_speak(key.underscore) }
          result
        end

        def keys
          guide = key_translation_mapping
          guide.keys.map{|key| guide[key] }
        end
        
        def get(key)
          ReportDecorator.new.decorate(@report[key] || @report[key_translation_mapping.invert[key]])
        end

        def has_key?(key)
          @report.keys.include?(key) || key_translation_mapping.values.include?(key)
        end

        def method_missing(method_name, *arguments, &block)
          if has_key?(method_name.to_s)
            get(method_name.to_s)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          has_key?(method_name.to_s) || super
        end
        
        def to_json(hash = {})
          result = {}
          @report.keys.each do |key|
            result[key_translation_mapping[key]] = ReportDecorator.new.decorate(@report[key])
          end
          result.to_json
        end
      end
 
      class KatelloToCandlepinTranslator
        CP_TO_KAT_SPEAK = {
          'consumer' => 'system',
          'owner' => 'system',
          'compliance' => 'subscription',
        }

        def to_katello_speak(input)
          CP_TO_KAT_SPEAK.keys.inject(input.clone) do |result, candlepin_keyword|
            result.gsub(candlepin_keyword, CP_TO_KAT_SPEAK[candlepin_keyword])
          end
        end
      end
      
      class ReportArrayDecorator
        include Enumerable

        def initialize(*members)
          @members = members
        end

        def each(&block)
          @members.each do |member|
            block.call(ReportDecorator.new.decorate(member))
          end
        end
      end
    end
  end
end
