require 'json'
require 'active_support/inflector'

class ReportFormatterTest < ActiveSupport::TestCase
  test 'to_json' do
    example = <<-EOF
    {
      "status" : {
        "status" : "valid",
        "date" : "2015-02-09T13:27:40.652+0000"
      },
      "consumer" : {
        "facts" : {
            "cpu.core(s)_per_socket": "4",
            "cpu.cpu(s)": "4",
            "cpu.cpu_socket(s)": "1",
            "cpu.thread(s)_per_core": "1"
        },
        "consumerState" : {
          "created" : "2015-02-09T13:27:35.578+0000",
          "deleted" : null
        },
        "name" : "test-consumer-BEcQrEdg",
        "owner" : {
          "displayName" : "ACME Corporation",
          "key" : "acme_corporation"
        },
        "lastCheckin" : "2015-02-09T13:27:37.809+0000",
        "uuid" : "0668eca4-2efe-4965-a2ea-610027164c4e"
      }
    }
    EOF
    resp = JSON.parse(example)
    decorator  = ::Actions::ForemanGutterball::ContentReports::ReportFormatter.new.format(resp)
    assert_equal decorator.system.owner.display_name, 'ACME Corporation'
  end
end
