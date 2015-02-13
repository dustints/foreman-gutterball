module Actions
  module ForemanGutterball
    module ContentReports
      class ReportFormatter
        def format(report)
          if report.is_a?(Hash)
            ::Actions::ForemanGutterball::ContentReports::ReportHashFormatter.new(report)
          elsif report.is_a?(Array)
            ::Actions::ForemanGutterball::ContentReports::ReportArrayFormatter.new(report)
          elsif report.is_a?(String)
            report
          elsif report.nil?
            "nil"
          else
            report.to_s
          end
        end

        #primative output rather than serilization
        def serialize(report)
          JSON.parse(::JSON.generate(format(report)))
        end
      end

      class ReportHashFormatter
        attr_accessor :report

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
          ReportFormatter.new.format(@report[key] || @report[key_translation_mapping.invert[key]])
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

        def to_hash
          result = {}
          @report.keys.each do |key|
            result[key_translation_mapping[key]] = ReportFormatter.new.format(@report[key])
          end
          result
        end

        def to_json(options = nil) 
          result = {}
          @report.keys.each do |key|
            result[key_translation_mapping[key]] = ReportFormatter.new.format(@report[key])
          end
          ::JSON.generate(result)
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

      class ReportArrayFormatter
        include Enumerable
        attr_accessor :members

        def initialize(members)
          @members = members.map{|m| ReportFormatter.new.format(m)}
        end

        def each(&block)
          @members.each do |member|
            block.call(member)
          end
        end
        
        def to_json(options = nil)
          ::JSON.generate(@members)
        end
      end
    end
  end
end
