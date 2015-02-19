require 'json'
require 'test_helper'

class ReportFormatterTest < ActiveSupport::TestCase
  EXAMPLE = <<-EOF
[ {
  "consumer" : {
    "uuid" : "7fbd515f-ade7-49a6-b2ac-c254d29dc0d5",
    "consumerState" : {
      "uuid" : "7fbd515f-ade7-49a6-b2ac-c254d29dc0d5",
      "owner" : "redhat",
      "created" : "2015-01-07T17:48:54.081+0000"
    },
    "name" : "sys-1-78313841",
    "username" : "admin",
    "entitlementStatus" : null,
    "serviceLevel" : "",
    "releaseVer" : null,
    "type" : {
      "label" : "system",
      "manifest" : false
    },
    "owner" : {
      "key" : "redhat",
      "displayName" : "redhat"
    },
    "entitlementCount" : 0,
    "lastCheckin" : null,
    "facts" : {
      "uname.machine" : "x86_64",
      "cpu.cpu_socket(s)" : "8"
    },
    "installedProducts" : [ {
      "productId" : "37060",
      "productName" : "37060",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "100000000000002",
      "productName" : "100000000000002",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "37069",
      "productName" : "37069",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "37065",
      "productName" : "37065",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "37068",
      "productName" : "37068",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "27060",
      "productName" : "27060",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "37067",
      "productName" : "37067",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "37062",
      "productName" : "37062",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "37070",
      "productName" : "37070",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    }, {
      "productId" : "37080",
      "productName" : "37080",
      "version" : null,
      "arch" : null,
      "status" : null,
      "startDate" : null,
      "endDate" : null
    } ],
    "guestIds" : [ ],
    "hypervisorId" : null,
    "environment" : null
  },
  "status" : {
    "status" : "invalid",
    "reasons" : [ {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37080",
        "name" : "37080"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "100000000000002",
        "name" : "100000000000002"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "27060",
        "name" : "27060"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37062",
        "name" : "37062"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37068",
        "name" : "37068"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37065",
        "name" : "37065"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37067",
        "name" : "37067"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37060",
        "name" : "37060"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37070",
        "name" : "37070"
      }
    }, {
      "key" : "NOTCOVERED",
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37069",
        "name" : "37069"
      }
    } ],
    "nonCompliantProducts" : [ "37065"
, "27060"
, "37062"
, "37069"
, "37068"
, "37067"
, "100000000000002"
, "37080"
, "37070"
, "37060" ]
,
    "compliantProducts" : [ ],
    "partiallyCompliantProducts" : [ ],
    "partialStacks" : [ ],
    "date" : "2015-01-07T17:48:56.290+0000"
  },
  "entitlements" : [ ],
  "date" : "2015-01-07T17:48:56.290+0000"
}, {
  "consumer" : {
    "uuid" : "1b275bc5-ed27-4f5d-b7e8-73fe46efeb95",
    "consumerState" : {
      "uuid" : "1b275bc5-ed27-4f5d-b7e8-73fe46efeb95",
      "owner" : "redhat",
      "created" : "2015-01-07T17:48:58.601+0000"
    }
  }
}]
  EOF

  test 'translating cp terms to katello terms' do
    resp = JSON.parse(EXAMPLE)
    formatted = ::ForemanGutterball::Formatters::ReportFormatter.new.format(resp)
    assert_equal formatted.first.system.system_state.system.to_s, 'redhat'
  end

  test 'json output' do
    resp = JSON.parse(EXAMPLE)
    json = ::JSON.generate(::ForemanGutterball::Formatters::ReportFormatter.new.format(resp))
    obj = ::JSON.parse(json)
    assert_equal obj.first['system']['system_state']['system'], 'redhat'
  end

  test 'flatten output' do
    resp = JSON.parse(EXAMPLE)
    wrapped = ::ForemanGutterball::Formatters::ReportFormatter.new.format(resp)
    flattened = ::ForemanGutterball::Formatters::ReportFormatter.new.flatten(wrapped)
    assert_equal flattened.first['system_system_state_system'], 'redhat'
  end
end
