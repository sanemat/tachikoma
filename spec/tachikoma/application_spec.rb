require 'tachikoma'
require 'tachikoma/application'
require 'fileutils'

describe Tachikoma::Application do
  before :all do
    ENV.update('BUILD_FOR' => 'test')
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
    ENV.update('BUILD_FOR' => nil)
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

  context 'if strategy is `bundler`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `bundler` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:bundler)
      Tachikoma::Application.run 'bundler'
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

  context 'if strategy is `none`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `none` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:none)
      Tachikoma::Application.run 'none'
    end
  end

  context 'if strategy is `david`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `david` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:david)
      Tachikoma::Application.run 'david'
    end
  end

  context 'if strategy is `composer`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `composer` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:composer)
      Tachikoma::Application.run 'composer'
    end
  end

  context 'if strategy is `cocoapods`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `cocoapods` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:cocoapods)
      Tachikoma::Application.run 'cocoapods'
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
    context 'include dot' do
      let(:identity) { 'example1/foo.bar.baz' }
      let(:url) { 'https://github.com/example1/foo.bar.baz.git' }
      it { expect(subject.repository_identity(url)).to eq identity }
    end
  end

  describe '#target_repository_user' do
    subject { described_class.new }
    let(:url) { 'https://github.com/example/example2.git' }
    let(:repos_user) { 'example' }
    let(:github_user) { 'me' }

    context 'valid type' do
      context 'fork' do
        let(:type) { 'fork' }
        it { expect(subject.target_repository_user(type, url, github_user)).to eq github_user }
      end
      context 'shared' do
        let(:type) { 'shared' }
        it { expect(subject.target_repository_user(type, url, github_user)).to eq repos_user }
      end
    end

    context 'invalid type' do
      let(:type) { 'invalid' }
      it { expect { subject.target_repository_user(type, url, github_user) }.to raise_error(InvalidType) }
    end
  end

  describe '#authorized_compare_url_with_type' do
    subject { described_class.new.authorized_compare_url_with_type(base_url, type, token, account) }
    let(:token) { 'token' }

    context 'valid type' do
      context 'fork' do
        let(:base_url) { 'https://github.com/can-not-write/example2.git' }
        let(:account) { 'readonly' }
        let(:type) { 'fork' }
        let(:authorized_compare_url) { 'https://token:x-oauth-basic@github.com/readonly/example2.git' }
        it { is_expected.to eq authorized_compare_url }
      end
      context 'shared' do
        let(:base_url) { 'https://github.com/writable/example2.git' }
        let(:account) { 'me' }
        let(:type) { 'shared' }
        let(:authorized_compare_url) { 'https://token:x-oauth-basic@github.com/writable/example2.git' }
        it { is_expected.to eq authorized_compare_url }
      end
    end

    context 'invalid type' do
      let(:base_url) { 'https://github.com/writable/example2.git' }
      let(:account) { 'me' }
      let(:type) { 'invalid' }
      # FIXME: Use `is_expected` ?
      it { expect { subject }.to raise_error(InvalidType) }
    end
  end

  describe '#authorized_base_url_with_type' do
    subject { described_class.new.authorized_base_url_with_type(base_url, type, token, account) }
    let(:token) { 'token' }

    context 'valid type' do
      context 'fork' do
        let(:base_url) { 'https://github.com/can-not-write/example2.git' }
        let(:account) { 'readonly' }
        let(:type) { 'fork' }
        let(:authorized_base_url) { 'https://token:x-oauth-basic@github.com/can-not-write/example2.git' }
        it { is_expected.to eq authorized_base_url }
      end
      context 'shared' do
        let(:base_url) { 'https://github.com/writable/example2.git' }
        let(:account) { 'me' }
        let(:type) { 'shared' }
        let(:authorized_base_url) { 'https://token:x-oauth-basic@github.com/writable/example2.git' }
        it { is_expected.to eq authorized_base_url }
      end
    end

    context 'invalid type' do
      let(:base_url) { 'https://github.com/writable/example2.git' }
      let(:account) { 'me' }
      let(:type) { 'invalid' }
      # FIXME: Use `is_expected` ?
      it { expect { subject }.to raise_error(InvalidType) }
    end
  end
end
