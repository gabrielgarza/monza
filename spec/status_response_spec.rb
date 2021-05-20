require 'spec_helper'

describe Monza::StatusResponse do
  context 'initial buy example' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/status_update_notifications/initial_buy.json", 'rb').read }
    let(:status_update) { described_class.new(response) }

    it { expect(status_update.environment).to eq 'Sandbox' }
    
    it { expect(status_update.latest_receipt).to eq 'base 64 string' }

    it { expect(status_update.auto_renew_product_id).to eq 'product_id.quarterly' }
    it { expect(status_update.auto_renew_status).to eq true }
    it { expect(status_update.notification_type).to eq Monza::StatusResponse::Type::INITIAL_BUY }
    it { expect(status_update.password).to eq 'password' }
    
    it { expect(status_update.password).to eq 'password' }
    it { expect(status_update.bundle_id).to eq 'co.bundle.id' }
    it { expect(status_update.bvrs).to eq 1004 }
    it { expect(status_update.item_id).to eq 1359898757 }
    
    it { expect(status_update.transaction_id).to eq "1000000383185294" }
    it { expect(status_update.original_transaction_id).to eq "1000000383185294" }

    purchase_date = DateTime.parse('2018-03-15 23:23:04 Etc/GMT')
    it { expect(status_update.purchase_date).to eq purchase_date }
    it { expect(status_update.purchase_date_ms).to eq purchase_date }
    it { expect(status_update.purchase_date_pst).to eq purchase_date }

    original_purchase_date = DateTime.parse('2018-03-15 23:23:05 Etc/GMT')
    it { expect(status_update.original_purchase_date).to eq original_purchase_date }
    it { expect(status_update.original_purchase_date_ms).to eq original_purchase_date }
    it { expect(status_update.original_purchase_date_pst).to eq original_purchase_date }
        
    expires_date = DateTime.parse('2018-03-16 00:23:04 Etc/GMT')
    it { expect(status_update.expires_date).to eq expires_date }
    it { expect(status_update.expires_date_ms).to eq expires_date }
    it { expect(status_update.expires_date_pst).to eq expires_date }

    it { expect(status_update.cancellation_date).to eq nil }
    it { expect(status_update.web_order_line_item_id).to eq '1000000038128113' }
    it { expect(status_update.quantity).to eq 1 }
    it { expect(status_update.unique_identifier).to eq '3a142176fee52ba64ddc3ba3b685786bd58cb4fe' }
    it { expect(status_update.unique_vendor_identifier).to eq 'D8E8B1EB-7A35-4E88-A21C-584E4FEB6543' }
    it { expect(status_update.is_in_intro_offer_period).to eq false }
    it { expect(status_update.is_trial_period).to eq false }
  end

  context 'renewal with unified receipt example' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/status_update_notifications/renewal_with_unified_receipt.json", 'rb').read }
    let(:status_update) { described_class.new(response) }

    it { expect(status_update.environment).to eq 'Sandbox' }
    
    it { expect(status_update.latest_receipt).to eq '<base64 latest receipt>' }

    it { expect(status_update.auto_renew_product_id).to eq 'product_id.monthly' }
    it { expect(status_update.auto_renew_status).to eq true }
    it { expect(status_update.notification_type).to eq Monza::StatusResponse::Type::RENEWAL }
    it { expect(status_update.password).to eq '[FILTERED]' }
    
    it { expect(status_update.transaction_id).to eq "1000000707558300" }
    it { expect(status_update.original_transaction_id).to eq "1000000715982567" }

    purchase_date = DateTime.parse('2020-07-16 14:36:42 Etc/GMT')
    it { expect(status_update.purchase_date).to eq purchase_date }
    it { expect(status_update.purchase_date_ms).to eq purchase_date }
    it { expect(status_update.purchase_date_pst).to eq purchase_date }

    original_purchase_date = DateTime.parse('2020-07-13 14:47:59 Etc/GMT')
    it { expect(status_update.original_purchase_date).to eq original_purchase_date }
    it { expect(status_update.original_purchase_date_ms).to eq original_purchase_date }
    it { expect(status_update.original_purchase_date_pst).to eq original_purchase_date }
        
    it { expect(status_update.cancellation_date).to eq nil }
    it { expect(status_update.web_order_line_item_id).to eq '1000000055398502' }
    it { expect(status_update.quantity).to eq 1 }
    it { expect(status_update.is_in_intro_offer_period).to eq false }
    it { expect(status_update.is_trial_period).to eq false }

    it { expect(status_update.latest_receipt_info.size).to eq 22 }

    it { expect(status_update.latest_receipt_info[1].expires_date).to eq DateTime.parse('2020-07-16 14:36:38 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[1].expires_date_ms).to eq DateTime.parse('2020-07-16 14:36:38 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[1].expires_date_pst).to eq DateTime.parse('2020-07-16 7:36:38 PST') }

    it { expect(status_update.latest_receipt_info[1].is_trial_period).to eq false }
    it { expect(status_update.latest_receipt_info[1].original_transaction_id).to eq '1000000715982567'}
    it { expect(status_update.latest_receipt_info[1].product_id).to eq 'product_id.monthly'}

    it { expect(status_update.latest_receipt_info[1].purchase_date).to eq DateTime.parse('2020-07-16 14:31:38 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[1].purchase_date_ms).to eq DateTime.parse('2020-07-16 14:31:38 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[1].purchase_date_pst).to eq DateTime.parse('2020-07-16 7:31:38 PST') }

    it { expect(status_update.latest_receipt_info[1].quantity).to eq 1 }
    it { expect(status_update.latest_receipt_info[1].transaction_id).to eq '1000000708938561' }
    it { expect(status_update.latest_receipt_info[1].web_order_line_item_id).to eq '1000000054104502' }

    it { expect(status_update.latest_receipt_info[21].expires_date).to eq DateTime.parse('2020-07-13 14:52:58 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[21].expires_date_ms).to eq DateTime.parse('2020-07-13 14:52:58 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[21].expires_date_pst).to eq DateTime.parse('2020-07-13 7:52:58 PST') }

    it { expect(status_update.latest_receipt_info[21].is_trial_period).to eq false }
    it { expect(status_update.latest_receipt_info[21].original_transaction_id).to eq '1000000715982567'}
    it { expect(status_update.latest_receipt_info[21].product_id).to eq 'product_id.monthly'}

    it { expect(status_update.latest_receipt_info[21].purchase_date).to eq DateTime.parse('2020-07-13 14:47:58 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[21].purchase_date_ms).to eq DateTime.parse('2020-07-13 14:47:58 Etc/GMT') }
    it { expect(status_update.latest_receipt_info[21].purchase_date_pst).to eq DateTime.parse('2020-07-13 7:47:58 PST') }

    it { expect(status_update.latest_receipt_info[21].quantity).to eq 1 }
    it { expect(status_update.latest_receipt_info[21].transaction_id).to eq '1000000704619139' }
    it { expect(status_update.latest_receipt_info[21].web_order_line_item_id).to eq '1000000054005913' }
  end


  context 'cancel example' do
    let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/status_update_notifications/cancel.json", 'rb').read }
    let(:status_update) { described_class.new(response) }


    it { expect(status_update.notification_type).to eq 'CANCEL' }
    it { expect(status_update.password).to eq 'password' }

    cancellation_date = DateTime.parse('2018-03-22 22:28:21 Etc/GMT')
    it { expect(status_update.cancellation_date).to eq cancellation_date }

  end



  # context 'latest receipt info' do
  #   let(:response) { JSON.parse File.open("#{Dir.pwd}/spec/response.json", 'rb').read }
  #   let(:verify) { described_class.new(response) }

  #   it 'latest_receipt_info' do
  #     latest_transaction = verify.latest_receipt_info.last

  #     expect(latest_transaction).not_to be_nil
  #     expect(latest_transaction.quantity).to eq 1
  #     expect(latest_transaction.transaction_id).to eq '1000000218147500'
  #     expect(latest_transaction.original_transaction_id).to eq '1000000218147500'
  #     expect(latest_transaction.product_id).to eq 'com.example.product_id'

  #     expect(latest_transaction.purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
  #     expect(latest_transaction.purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

  #     expect(latest_transaction.original_purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
  #     expect(latest_transaction.original_purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

  #     expect(latest_transaction.expires_date).to eq DateTime.parse('2016-06-17 01:32:28 Etc/GMT')
  #     expect(latest_transaction.expires_date_ms).to eq Time.zone.at("1466127148000".to_i / 1000)

  #     expect(latest_transaction.is_trial_period).to eq true
  #     expect(latest_transaction.cancellation_date).to be_nil
  #   end
  # end

  # context 'latest receipt info with cancellation' do
  #   let(:cancellation_response) { JSON.parse File.open("#{Dir.pwd}/spec/cancellation_response.json", 'rb').read }
  #   let(:verify) { described_class.new(cancellation_response) }

  #   it 'latest_receipt_info' do
  #     latest_transaction = verify.latest_receipt_info.last

  #     expect(latest_transaction).not_to be_nil
  #     expect(latest_transaction.quantity).to eq 1
  #     expect(latest_transaction.transaction_id).to eq '1000000218147500'
  #     expect(latest_transaction.original_transaction_id).to eq '1000000218147500'
  #     expect(latest_transaction.product_id).to eq 'com.example.product_id'

  #     expect(latest_transaction.purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
  #     expect(latest_transaction.purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

  #     expect(latest_transaction.original_purchase_date).to eq DateTime.parse('2016-06-17 01:27:28 Etc/GMT')
  #     expect(latest_transaction.original_purchase_date_ms).to eq Time.zone.at("1466126848000".to_i / 1000)

  #     expect(latest_transaction.expires_date).to eq DateTime.parse('2016-06-17 01:32:28 Etc/GMT')
  #     expect(latest_transaction.expires_date_ms).to eq Time.zone.at("1466127148000".to_i / 1000)

  #     expect(latest_transaction.is_trial_period).to eq true
  #     expect(latest_transaction.cancellation_date).to eq DateTime.parse('2016-06-17 01:37:28 Etc/GMT')
  #   end
  # end
end
