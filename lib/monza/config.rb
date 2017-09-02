require 'time'
require 'active_support/core_ext/time'

module Monza

  # Set default for Time zone if none has been set
  # Default is UTC
  Time.zone_default ||= Time.find_zone!("UTC")

end
