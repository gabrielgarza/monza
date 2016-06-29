require 'spec_helper'

describe Monza::Receipt do
  context 'verification receipt' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
    let(:receipt) { described_class.new(response['receipt']) }

    # TODO: verify DateTime for:
    #     + :@receipt_creation_date,
    #      + :@receipt_creation_date_ms,
    #      + :@receipt_creation_date_pst,
    #      + :@request_date,
    #      + :@request_date_ms,
    #      + :@request_date_pst,
    #      + :@original_purchase_date,
    #      + :@original_purchase_date_ms,
    #      + :@original_purchase_date_pst,

    it { expect(receipt.version_external_identifier).to eq 0 }
    it { expect(receipt.app_item_id).to eq 0 }
    it { expect(receipt.download_id).to eq 100 }
    it { expect(receipt.application_version).to eq '58' }
    it { expect(receipt.original_application_version).to eq '1.0' }
    it { expect(receipt.receipt_type).to eq 'ProductionSandbox' }
    it { expect(receipt.bundle_id).to eq 'com.example.app' }
    it 'time zone' do
      expect(receipt.receipt_creation_date).to eq DateTime.parse('2016-06-17 01:54:26 Etc/GMT')
      expect(receipt.receipt_creation_date_ms).to eq Time.zone.at("1466128466000".to_i / 1000)

      expect(receipt.request_date).to eq DateTime.parse('2016-06-17 17:34:41 Etc/GMT')
      expect(receipt.request_date_ms).to eq Time.zone.at("1466184881174".to_i / 1000)

      expect(receipt.original_purchase_date).to eq DateTime.parse('2013-08-01 07:00:00 Etc/GMT')
      expect(receipt.original_purchase_date_ms).to eq Time.zone.at("1375340400000".to_i / 1000)
    end

    it 'receipt' do
      in_app = receipt.in_app.first

      # TODO: vefify purchase_date and original_purchase_date

      expect(in_app).not_to be_nil
      expect(in_app.quantity).to eq 1
      expect(in_app.transaction_id).to eq '1000000218147651'
      expect(in_app.original_transaction_id).to eq '1000000218147500'
      expect(in_app.product_id).to eq 'com.example.product_id'

      expect(in_app.purchase_date).to eq DateTime.parse('2016-06-17 01:32:28 Etc/GMT')
      expect(in_app.purchase_date_ms).to eq Time.zone.at("1466127148000".to_i / 1000)

      expect(in_app.original_purchase_date).to eq DateTime.parse('2016-06-17 01:30:33 Etc/GMT')
      expect(in_app.original_purchase_date_ms).to eq Time.zone.at("1466127033000".to_i / 1000)

      expect(in_app.expires_date).to eq DateTime.parse('2016-06-17 01:37:28 Etc/GMT')
      expect(in_app.expires_date_ms).to eq Time.zone.at("1466127448000".to_i / 1000)

      expect(in_app.is_trial_period).to eq false
    end

  end
end
