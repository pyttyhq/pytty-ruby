RSpec.describe Pytty::Daemon::Cli do
  it do
    k = pyttyd "version"
    expect(k.out.chomp).to eq Pytty::VERSION.to_s
  end
end
