# frozen_string_literal: true

require 'test_helper'
require 'date'
require 'time'

module CzechPostB2bClient
  module Test
    class GetParcelStateBuilderTest < Minitest::Test
      attr_reader :parcel_codes

      def setup
        @expected_build_time_str = '2019-12-12T12:34:56.789+01:00'
        @contract_id = '123456I'
        @request_id = 42
        @build_time = Time.parse(@expected_build_time_str)

        @parcel_codes = %w[RR123456789E RR123456789F RR123456789G]

        setup_configuration(contract_id: @contract_id)
      end

      def expected_xml
        <<~XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <b2bRequest xmlns=\"https://b2b.postaonline.cz/schema/B2BCommon-v1\" xmlns:ns2=\"https://b2b.postaonline.cz/schema/POLServices-v1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/latest_xsds/B2BCommon.xsd\" xsi:schemaLocation=\"https://b2b.postaonline.cz/schema/POLServices-v1 https://raw.githubusercontent.com/foton/czech_post_b2b_client/master/documents/latest_xsds/B2BPOLServices.xsd\">
            <header>
              <idExtTransaction>#{@request_id}</idExtTransaction>
              <timeStamp>#{@expected_build_time_str}</timeStamp>
              <idContract>#{@contract_id}</idContract>
            </header>
            <serviceData>
              <ns2:getParcelState>
                <ns2:idParcel>#{parcel_codes[0]}</ns2:idParcel>
                <ns2:idParcel>#{parcel_codes[1]}</ns2:idParcel>
                <ns2:idParcel>#{parcel_codes[2]}</ns2:idParcel>
                <ns2:language>cs</ns2:language>
              </ns2:getParcelState>
            </serviceData>
          </b2bRequest>
        XML
      end

      def test_it_build_correct_xml
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder.call(parcel_codes: parcel_codes,
                                                                                    request_id: @request_id)
          assert builder.success?
          assert_equal expected_xml, builder.result
        end
      end

      def test_it_assings_request_id_if_it_is_not_present
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder.call(parcel_codes: parcel_codes)

          assert builder.success?
          assert_equal expected_xml.gsub(">#{@request_id}</", '>1</'), builder.result

          skip 'TODO: it increases such id for next requests; do not allow to overide it(?) '
        end
      end

      def test_allows_max_10_parcel_codes
        parcel_codes_in_limit = 10.times.collect { |i| "RR123#{i + 100}T" }

        builder = CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder.call(parcel_codes: parcel_codes_in_limit)

        assert builder.success?

        parcel_codes_over_limit = parcel_codes_in_limit + ['RR666111E']
        builder = CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder.call(parcel_codes: parcel_codes_over_limit)

        assert builder.failed?
        assert_includes builder.errors[:parcel_codes], 'Maximum of 10 parcel codes are allowed!'
      end

      def test_requires_at_least_1_parcel_code
        builder = CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder.call(parcel_codes: [])

        assert builder.failed?
        assert_includes builder.errors[:parcel_codes], 'Minimum of 1 parcel code is required!'

        builder = CzechPostB2bClient::RequestBuilders::GetParcelStateBuilder.call(parcel_codes: ['RR666111E'])

        assert builder.success?
      end
    end
  end
end
