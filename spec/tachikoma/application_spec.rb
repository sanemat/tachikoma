require 'tachikoma'
require 'tachikoma/application'
require 'fileutils'

describe Tachikoma::Application do
  before :all do
    ENV.update({ 'BUILD_FOR' => 'test' })
    open(File.join(File.dirname(__FILE__), '..', '..', 'data', 'test.yaml'), 'w') { |f|
      f.puts <<YAML
url:
  'https://github.com/sanemat/bot-motoko-tachikoma.git'
type:
  'fork'
YAML
    }
  end

  after :all do
    ENV.update({ 'BUILD_FOR' => nil })
    FileUtils.rm_f File.join(File.dirname(__FILE__), '..', '..', 'data', 'test.yaml')
  end

  context 'if strategy is `bundle`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `bundle` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:bundle)
      Tachikoma::Application.run 'bundle'
    end
  end

  context 'if strategy is `carton`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `carton` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:carton)
      Tachikoma::Application.run 'carton'
    end
  end

  describe '#bundler_parallel_option' do
    subject { described_class.new }

    context 'bundler does not support parallel' do
      let(:bundler_version) { '1.3.5' }
      let(:parallel_number) { 3 }
      it 'returns nil' do
        expect(subject.bundler_parallel_option(bundler_version, parallel_number)).to be_nil
      end
    end

    context 'bundler supports parallel' do
      let(:bundler_version) { '1.5.0' }

      context 'parallel less than 1' do
        let(:parallel_number) { 1 }
        it 'returns nil' do
          expect(subject.bundler_parallel_option(bundler_version, parallel_number)).to be_nil
        end
      end

      context 'parallel above 1' do
        let(:parallel_number) { 3 }
        let(:parallel_option) { "--jobs=#{parallel_number}" }
        it 'returns parallel option' do
          expect(subject.bundler_parallel_option(bundler_version, parallel_number)).to eq parallel_option
        end
      end
    end
  end

  describe '#repository_identity' do
    subject { described_class.new }
    let(:identity) { 'example1/example2' }

    context 'https with .git' do
      let(:url) { 'https://github.com/example1/example2.git' }
      it { expect(subject.repository_identity(url)).to eq identity }
    end
    context 'https without .git' do
      let(:url) { 'https://github.com/example1/example2' }
      it { expect(subject.repository_identity(url)).to eq identity }
    end
    context 'https with trail slash' do
      let(:url) { 'https://github.com/example1/example2/' }
      it { expect(subject.repository_identity(url)).to eq identity }
    end
  end
end
