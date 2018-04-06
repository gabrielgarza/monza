require 'spec_helper'

describe Monza::VerificationResponse do
  context 'verification example' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
    let(:verify) { described_class.new(response) }
    let(:cancellation_response) { JSON.parse File.open("#{Dir.pwd}/spec/cancellation_response.json", 'rb').read }
    let(:cancellation_receipt) { described_class.new(cancellation_response['receipt']) }

    it { expect(verify.status).to eq 0 }
    it { expect(verify.environment).to eq 'Sandbox' }
    it { expect(verify.receipt.class).to eq Monza::Receipt }
    it { expect(verify.latest_receipt_info).not_to be_nil }
    it { expect(verify.latest_receipt).to eq 'base 64 string' }
  end

  context 'vefification response error' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/bad_response.json", 'rb').read }
    let(:verify) { described_class.new(response) }

    it { expect(verify.status).to eq 21_003 }
    it do
      error = described_class::VerificationError.new(response['status'])

      expect(error.message).to eq 'The receipt could not be authenticated.'
    end
  end

  context 'latest receipt info' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
    let(:verify) { described_class.new(response) }

    it 'latest_receipt_info' do
      latest_transaction = verify.latest_receipt_info.last

      expect(latest_transaction).not_to be_nil
      expect(latest_transaction.quantity).to eq 1
      expect(latest_transaction.transaction_id).to eq '1000000218147500'
      expect(latest_transaction.original_transaction_id).to eq '1000000218147500'
      expect(latest_transaction.product_id).to eq 'com.example.product_id'

      expect(latest_transaction.purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
      expect(latest_transaction.purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

      expect(latest_transaction.original_purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
      expect(latest_transaction.original_purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

      expect(latest_transaction.expires_date_formatted).to eq DateTime.parse('2016-06-17 01:32:28 Etc/GMT')
      expect(latest_transaction.expires_date).to eq Time.zone.at("1466127148000".to_i / 1000)

      expect(latest_transaction.is_trial_period).to eq true
      expect(latest_transaction.cancellation_date).to be_nil
    end
  end

  context 'latest receipt info with cancellation' do
    let(:cancellation_response) { JSON.parse File.open("#{Dir.pwd}/spec/cancellation_response.json", 'rb').read }
    let(:verify) { described_class.new(cancellation_response) }

    it 'latest_receipt_info' do
      latest_transaction = verify.latest_receipt_info.last

      expect(latest_transaction).not_to be_nil
      expect(latest_transaction.quantity).to eq 1
      expect(latest_transaction.transaction_id).to eq '1000000218147500'
      expect(latest_transaction.original_transaction_id).to eq '1000000218147500'
      expect(latest_transaction.product_id).to eq 'com.example.product_id'

      expect(latest_transaction.purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
      expect(latest_transaction.purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

      expect(latest_transaction.original_purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
      expect(latest_transaction.original_purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

      expect(latest_transaction.expires_date_formatted).to eq DateTime.parse('2016-06-17 01:32:28 Etc/GMT')
      expect(latest_transaction.expires_date).to eq Time.zone.at("1466127148000".to_i / 1000)

      expect(latest_transaction.is_trial_period).to eq true
      expect(latest_transaction.cancellation_date).to eq DateTime.parse('2016-06-17 01:37:28 Etc/GMT')
    end
  end
end
