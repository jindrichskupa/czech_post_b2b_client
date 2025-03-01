# frozen_string_literal: true

module CzechPostB2bClient
  module RequestBuilders
    class GetResultParcelsBuilder < BaseBuilder
      attr_reader :transaction_id

      def initialize(transaction_id:, request_id: 1)
        super()
        @transaction_id = transaction_id
        @request_id = request_id
      end

      private

      def validate_data
        return unless transaction_id.nil? || transaction_id == ''

        errors.add(:transaction_id, 'Must be present!')
        fail!
      end

      def service_data_struct
        # No <serviceDate> element in this case
        new_element('idTransaction', value: transaction_id)
      end
    end
  end
end
