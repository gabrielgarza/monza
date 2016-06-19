require "monza/version"
require "monza/client"
require "monza/verification_response"
require "monza/receipt"
require "monza/transaction_receipt"

class Monza

  def self.verify(data, options = {})
    client = Client.production

    begin
      client.verify(data, options)
    rescue VerificationError => error
      case error.code
      when 21007 # This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.
        client = Client.development
        retry
      when 21008 # This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.
        client = Client.production
        retry
      else
        raise error
      end
    end
  end

end
