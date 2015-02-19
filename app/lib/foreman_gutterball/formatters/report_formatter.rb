module ForemanGutterball
  module Formatters
    class ReportFormatter
      def format(report)
        if report.is_a?(Hash)
          ReportHashFormatter.new(report)
        elsif report.is_a?(Array)
          ReportArrayFormatter.new(report)
        else
          ReportPrimativeFormatter.new(report)
        end
      end

      def format_parent(parent, key)
        parent.nil? ? key : "#{parent}_#{key}"
      end

      def flatten(report, parent = nil,items = {})
       if(report.is_a?(ReportPrimativeFormatter))
         items[parent] = report.to_s
         return items
       elsif ((report).is_a?(ReportHashFormatter))
         out = report.keys.reduce({}) do |res, key|
           items.merge(flatten(report.get(key), format_parent(parent, key) , items) )
         end
         return out
       elsif ((report).is_a?(ReportArrayFormatter))
         flatten_array(report, parent, items)
       end
      end

      def flatten_array(report, parent, items)
         if(parent.nil?)
           result = []
           report.each_with_index do |r, index|
             result << flatten(r, parent.nil? ? nil : format_parent(parent, index.to_s))
           end
           return result
         else
           result = {}
           report.each_with_index do |r, index|
             name = parent.nil? ? nil : format_parent(parent, index.to_s)
             result[name] = flatten(r, name, items)
           end
           return result.merge(items)
         end
      end

      # primative output rather than serilization
      def serialize(report)
        JSON.parse(::JSON.generate(format(report)))
      end
    end

    class ReportPrimativeFormatter
      def initialize(wrapped)
        @wrapped = wrapped
      end

      def to_s
        @wrapped.to_s || 'nil'
      end

      def to_json(*)
        @wrapped.to_json
      end
    end

    class ReportHashFormatter
      attr_accessor :report

      def initialize(report)
        @report = report
      end

      def key_translation_mapping
        result = {}
        @report.keys.each { |key| result[key] = KatelloToCandlepinTranslator.new.to_katello_speak(key.underscore) }
        result
      end

      def keys
        guide = key_translation_mapping
        guide.keys.map { |key| guide[key] }
      end

      def get(key)
        ReportFormatter.new.format(@report[key] || @report[key_translation_mapping.invert[key]])
      end

      def key?(key)
        @report.keys.include?(key) || key_translation_mapping.values.include?(key)
      end

      def method_missing(method_name, *arguments, &block)
        if key?(method_name.to_s)
          get(method_name.to_s)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        key?(method_name.to_s) || super
      end

      def to_json(*)
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
        'compliance' => 'subscription'
      }

      def to_katello_speak(input)
        CP_TO_KAT_SPEAK.keys.reduce(input.clone) do |result, candlepin_keyword|
          result.gsub(candlepin_keyword, CP_TO_KAT_SPEAK[candlepin_keyword])
        end
      end
    end

    class ReportArrayFormatter
      include Enumerable
      attr_accessor :members

      def initialize(members)
        @members = members.map { |m| ReportFormatter.new.format(m) }
      end

      def each(&block)
        @members.each do |member|
          block.call(member)
        end
      end

      def to_json(*)
        ::JSON.generate(@members)
      end
    end
  end
end
