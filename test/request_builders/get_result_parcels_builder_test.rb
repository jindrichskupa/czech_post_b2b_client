# frozen_string_literal: true

require 'test_helper'
require 'date'
require 'time'

module CzechPostB2bClient
  module Test
    class GetResultParcelsBuilderTest < Minitest::Test
      attr_reader :transaction_id

      def setup
        @expected_build_time_str = '2019-12-12T12:34:56.789+01:00'
        @contract_id = '123456I'
        @request_id = 42
        @build_time = Time.parse(@expected_build_time_str)

        @transaction_id = '1C6921F2-0153-4000-E000-21F00AA06329'

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
            <idTransaction>#{@transaction_id}</idTransaction>
          </b2bRequest>
        XML
      end

      def test_it_build_correct_xml
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder.call(transaction_id: transaction_id,
                                                                                      request_id: @request_id)
          assert builder.success?
          assert_equal expected_xml, builder.result
        end
      end

      def test_it_assings_request_id_if_it_is_not_present
        Time.stub(:now, @build_time) do
          builder = CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder.call(transaction_id: transaction_id)

          assert builder.success?
          assert_equal expected_xml.gsub(">#{@request_id}</", '>1</'), builder.result
        end
      end

      def test_it_requires_transaction_id
        builder = CzechPostB2bClient::RequestBuilders::GetResultParcelsBuilder.call(transaction_id: '')

        assert builder.failed?
        assert_includes builder.errors[:transaction_id], 'Must be present!'
      end
    end
  end
end
