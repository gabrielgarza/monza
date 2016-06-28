require 'spec_helper'

describe Monza::VerificationResponse do
  context 'verification example' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
    let(:verify) { described_class.new(response) }

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
end
