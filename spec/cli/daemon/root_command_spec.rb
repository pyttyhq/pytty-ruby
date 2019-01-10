require "kommando"
RSpec.describe Pytty::Daemon::Cli do
  it do
    k = pyttyd
    expect(k.out).to match "🚽 pyttyd"
  end
end
