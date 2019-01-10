RSpec.describe Pytty::Client::Cli do
  it do
    k = pytty "version"
    expect(k.out.chomp).to eq Pytty::VERSION.to_s
  end
end
