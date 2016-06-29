require 'time'
require 'active_support/core_ext/time'

module Monza

  # Set default for Time zone if none has been set
  # Default is UTC
  Time.zone = Time.zone ? Time.zone : "UTC"


end
