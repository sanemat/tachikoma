require 'tachikoma/settings'
describe Tachikoma do
  describe '.root_path' do
    let(:somewhere) { '/path/to/somewhere' }
    let(:datapath) { somewhere + '/data' }
    let(:repospath) { somewhere + '/repos' }

    before :each do
      allow(Dir).to receive(:pwd).and_return(somewhere)
    end

    it { expect(described_class.root_path).to eq Pathname.new(somewhere) }
    it { expect(described_class.data_path).to eq Pathname.new(datapath) }
    it { expect(described_class.repos_path).to eq Pathname.new(repospath) }
  end
end
