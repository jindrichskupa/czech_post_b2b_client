# frozen_string_literal: true

require 'test_helper'

module CzechPostB2bClient
  module Test
    class GetParcelsPrintingParserTest < Minitest::Test
      DO_NOT_CHECK = 'we do not care about PDF content'

      def test_it_parses_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: b2b_ok_response)

        assert parser.success?
        compare_structs(expected_ok_struct, parser.result)
      end

      def test_it_parses_real_pdf_response_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: b2b_real_pdf_response)

        assert parser.success?

        expected_struct = expected_ok_real_pdf_struct
        result_struct = parser.result
        # pdf_file_content = result_struct[:printings][:pdf_content]
        # File.write('address_sheets.pdf', pdf_file_content)

        compare_structs(expected_struct, result_struct)
      end

      def test_it_parses_real_zpl_response_to_correct_structure
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: b2b_real_zpl_response)

        assert parser.success?, parser.errors

        expected_struct = expected_ok_real_zpl_struct
        result_struct = parser.result

        puts parser.result
        # zpl_file_content = result_struct[:printings][:zpl_content]
        # File.write('address_sheets.zpl', zpl_file_content)

        compare_structs(expected_struct, result_struct)
      end

      def test_it_handles_errors_in_response
        parser = CzechPostB2bClient::ResponseParsers::GetParcelsPrintingParser.call(xml: b2b_bad_response)

        assert parser.success?
        compare_structs(expected_real_wrong_combination_struct, parser.result)
      end

      def compare_structs(expected_struct, actual_struct) # rubocop:disable Metrics/AbcSize
        if expected_struct[:printings][:pdf_content] == DO_NOT_CHECK
          expected_struct[:printings].delete(:pdf_content)
          actual_struct[:printings].delete(:pdf_content)
        end

        if expected_struct[:printings][:zpl_content] == DO_NOT_CHECK
          expected_struct[:printings].delete(:zpl_content)
          actual_struct[:printings].delete(:zpl_content)
        end

        assert_equal expected_struct[:printings][:zpl_content], actual_struct[:printings][:zpl_content]
        assert_equal expected_struct[:printings][:pdf_content], actual_struct[:printings][:pdf_content]
        assert_equal expected_struct, actual_struct
      end

      def expected_ok_struct
        {
          printings: {
            options: {
              customer_id: 'EE89',
              contract_number: '12345678',
              template_id: 20, # 7 => adresni stitek (alonz) - samostatny
              margin_in_mm: { top: 2, left: 1 },
              position_order: 3
            },
            pdf_content: 'very big pdf extracted from base64 string'
          },
          request: { created_at: Time.parse('2016-03-12T10:00:34.573Z'),
                     contract_id: '25195667001',
                     request_id: '42' },
          response: { created_at: Time.parse('2016-02-18T16:00:34.913Z'), state: { code: 1, text: 'OK' } }
        }
      end

      def expected_ok_real_pdf_struct
        {
          printings: {
            options: {
              customer_id: 'L03053',
              contract_number: '25195667001',
              template_id: 24, # 'obalka 3 - B4'
              margin_in_mm: { top: 5, left: 3 },
              position_order: 0
            },
            pdf_content: DO_NOT_CHECK
          },
          request: { created_at: Time.parse('2020-03-17T08:58:02.874Z'),
                     contract_id: '25195667001',
                     request_id: '1' },
          response: { created_at: Time.parse('2020-03-17T09:58:05.529Z'), state: { code: 1, text: 'OK' } }
        }
      end

      def expected_ok_real_zpl_struct
        {
          printings: {
            options: {
              customer_id: 'L03051',
              contract_number: '356936003',
              template_id: 201, # 'Harmonizovaný štítek bianco - (Zebra - 100x150); nejde o PDF'
              margin_in_mm: { top: 0, left: 0 },
              position_order: 0
            },
            zpl_content: File.read(File.join(fixtures_dir, 'known_responses', 'real_sheet.zpl'))
          },
          request: { created_at: Time.parse('2022-04-07T08:57:26.923+02:00'),
                     contract_id: '356936003',
                     request_id: '1' },
          response: { created_at: Time.parse('2022-04-07T08:57:27.135Z'), state: { code: 1, text: 'OK' } }
        }
      end

      def expected_real_wrong_combination_struct
        {
          printings: {
            options: {
              customer_id: 'L03053',
              contract_number: '25195667001',
              template_id: 73, # 'obalka 3 - B4'
              margin_in_mm: { top: 5, left: 3 },
              position_order: 0
            },
            pdf_content: nil
          },
          request: { created_at: Time.parse('2020-03-17T08:58:02.874Z'),
                     contract_id: '25195667001',
                     request_id: '1' },
          response: { created_at: Time.parse('2020-03-17T09:58:05.529Z'),
                      state: { code: 378, text: 'INVALID_PREFIX_COMBINATION' } }
        }
      end

      def b2b_real_pdf_response
        fixture_response_xml('getParcelsPrinting_ok_real_pdf.xml')
      end

      def b2b_real_zpl_response
        fixture_response_xml('getParcelsPrinting_ok_real_zpl.xml')
      end

      def b2b_ok_response
        fixture_response_xml('getParcelsPrinting_ok_from_xsd.xml')
      end

      def b2b_bad_response
        fixture_response_xml('getParcelsPrinting_wrong_combination.xml')
      end
    end
  end
end

# <complexType name="doPrintingHeaderResult">
#  <annotation>
#     <documentation xml:lang="cs">Hlavičková data výsledku tisku</documentation>
#  </annotation>
#  <sequence>
#   <element name="doPrintingHeader" type="tns:doPrintingHeader" minOccurs="0">
#     <annotation>
#       <documentation xml:lang="cs">Vlastní hlavička pro tisk</documentation>
#     </annotation>
#   </element>
#   <element name="doPrintingStateResponse" type="tns:doParcelStateResponse">
#     <annotation>
#       <documentation xml:lang="cs">
#         responseCode    responseText                Popis
#         ==================================================================================
#            1            OK                                              Data parametrů zpracování v pořádku
#            2            INTERNALL_ERROR                                 Jiná chyba systému
#          100            INVALID_PARCEL_CODE                             Neplatné ID zásilky
#          378            INVALID_PREFIX_COMBINATION                      Zásilka je chybně přiřazena k id tiskové šablony
#          379            PARCEL_DOES_NOT_MEET_THE_REQUIREMENTS_FORM      Parametry zásilky nesplňují podmínky požadovaného formuláře
#          380            NO_CONTRACT_SERVICE_RETURN_RECEIPT              K formuláři není sjednána smlouva ke službě Dodejka
#        </documentation>
#      </annotation>
#    </element>
#  </sequence>
# </complexType>
