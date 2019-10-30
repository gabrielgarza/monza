require 'spec_helper'

describe Monza::RenewalInfo do
  context 'pending renewal info' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
    let(:renewal_info) { described_class.new(response['pending_renewal_info'].first) }

    it { expect(renewal_info.product_id).to eq "product_id" }
    it { expect(renewal_info.original_transaction_id).to eq "1000000218147500" }
    it { expect(renewal_info.expiration_intent).to eq "1" }
    it { expect(renewal_info.will_renew).to eq false }
    it { expect(renewal_info.is_in_billing_retry_period).to eq false }
    it { expect(renewal_info.auto_renew_product_id).to eq "renew_product_id" }
    it do
      expect(renewal_info.grace_period_purchase_date).to eq DateTime.parse('2013-08-01 07:00:00 Etc/GMT')
      expect(renewal_info.grace_period_purchase_date_ms).to eq Time.zone.at("1375340400000".to_i / 1000)
    }
  end
end
