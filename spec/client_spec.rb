require 'spec_helper'

describe Monza::Client do
  describe 'verification_url' do
    context 'development' do
      it 'should have correct url' do
        expect(Monza::Client.development.verification_url).to eq 'https://sandbox.itunes.apple.com/verifyReceipt'
      end
    end

    context 'production' do
      it 'should have correct url' do
        expect(Monza::Client.production.verification_url).to eq 'https://buy.itunes.apple.com/verifyReceipt'
      end
    end
  end
end
