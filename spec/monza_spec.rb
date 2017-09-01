require 'spec_helper'

describe Monza do
  it 'has a version number' do
    expect(Monza::VERSION).not_to be nil
  end

  it 'time zone' do
    expect(Thread.current[:time_zone]).to be nil
    expect(Time.zone_default).not_to be nil
  end

  # it 'does something useful' do
  #   expect(false).to eq(true)
  # end
end
