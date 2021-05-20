require 'spec_helper'
require 'active_support/time_with_zone.rb'
require 'active_support/core_ext/numeric/time.rb'

describe Monza::VerificationResponse do
  def replace_expires_date(hash, time)
    hash.merge!(
      "expires_date" => time.to_s,
      "expires_date_ms" => (time.to_i * 1000).to_s,
      "expires_date_pst" => time.in_time_zone('America/Los_Angeles').to_s
    )
  end

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

      expect(latest_transaction.expires_date).to eq DateTime.parse('2016-06-17 01:32:28 Etc/GMT')
      expect(latest_transaction.expires_date_ms).to eq Time.zone.at("1466127148000".to_i / 1000)

      expect(latest_transaction.is_trial_period).to eq true
      expect(latest_transaction.is_in_intro_offer_period).to eq true
      expect(latest_transaction.cancellation_date).to be_nil

      expect(latest_transaction.original_attributes).to be_present
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

      expect(latest_transaction.expires_date).to eq DateTime.parse('2016-06-17 01:32:28 Etc/GMT')
      expect(latest_transaction.expires_date_ms).to eq Time.zone.at("1466127148000".to_i / 1000)

      expect(latest_transaction.is_trial_period).to eq true
      expect(latest_transaction.cancellation_date).to eq DateTime.parse('2016-06-17 01:37:28 Etc/GMT')
      expect(latest_transaction.cancellation_date_ms).to eq Time.zone.at("1466127848000".to_i / 1000)
      expect(latest_transaction.cancellation_date_pst).to eq DateTime.parse("2016-06-16 18:37:28 PST")
      expect(latest_transaction.cancellation_reason).to eq "0"
    end
  end

  describe 'is_subscription_active?' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
    let(:verify) { described_class.new(response) }
    subject { verify.is_subscription_active? }

    context 'for a receipt with expiration date in the past' do
      it { is_expected.to be false }
    end

    context 'for a receipt with expiration date in the future' do
      let(:verify) do
        response["receipt"]["in_app"].each do |in_app|
          replace_expires_date(in_app, 4.days.from_now)
        end
        response.dig('unified_receipt', 'latest_receipt_info').each do |lri|
          replace_expires_date(lri, 4.days.from_now)
        end

        described_class.new(response)
      end

      context 'without cancellation date' do
        it { is_expected.to be true }
      end

      context 'with cancellatioin date' do
        let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/cancellation_response.json", 'rb').read }

        it { is_expected.to be false }
      end
    end
  end

  describe 'is_any_subscription_active?' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
    let(:verify) { described_class.new(response) }
    subject { verify.is_any_subscription_active? }

    context 'for a receipt with expiration date in the past' do
      it { is_expected.to be false }
    end

    context 'for a receipt with expiration date in the future' do
      let(:verify) do
        response["receipt"]["in_app"].each do |in_app|
          replace_expires_date(in_app, 4.days.from_now)
        end
        response.dig('unified_receipt', 'latest_receipt_info').each do |lri|
          replace_expires_date(lri, 4.days.from_now)
        end

        described_class.new(response)
      end

      context 'without cancellation date' do
        it { is_expected.to be true }
      end

      context 'with cancellation date' do
        let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/cancellation_response.json", 'rb').read }

        it { is_expected.to be false }
      end
    end

    context 'when the receipts are not in order and the newest one is not the last' do
      let(:verify) do
        response['receipt']['in_app'].each do |in_app|
          replace_expires_date(in_app, 4.days.from_now)
        end
        response.dig('unified_receipt', 'latest_receipt_info').each do |lri|
          replace_expires_date(lri, 4.days.from_now)
        end

        # If this is the last receipt, change the expires date
        replace_expires_date(response.dig('unified_receipt', 'latest_receipt_info').last, 4.days.ago)

        described_class.new(response)
      end

      context 'without cancellation date' do
        it { is_expected.to be true }
      end
    end

    context 'when there is no active receipt' do
      let(:verify) do
        response['receipt']['in_app'].each do |in_app|
          replace_expires_date(in_app, 4.days.ago)
        end
        response.dig('unified_receipt', 'latest_receipt_info').each do |lri|
          replace_expires_date(lri, 4.days.ago)
        end

        described_class.new(response)
      end

      context 'without cancellation date' do
        it { is_expected.to be false }
      end
    end

    context 'when there is a receipt without an expiration date' do
      let(:verify) do
        response['receipt']['in_app'].each do |in_app|
          replace_expires_date(in_app, 4.days.from_now)
        end
        response.dig('unified_receipt', 'latest_receipt_info').each do |lri|
          replace_expires_date(lri, 4.days.from_now)
        end

        # If this is the last receipt, change the expires date to be nil
        response.dig('unified_receipt', 'latest_receipt_info').last.merge!(
          'expires_date' => nil,
          'expires_date_ms' => nil,
          'expires_date_pst' => nil
        )

        described_class.new(response)
      end

      context 'without cancellation date' do
        it { is_expected.to be true }
      end
    end
  end
end
