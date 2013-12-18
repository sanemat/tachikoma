require 'spec_helper'
require 'rake'
require 'tachikoma/tasks'

describe 'app.rake' do
  describe 'tachikoma:pull_request' do
    context 'when github returns 422 UnprocessableEntity' do
      before do
        allow(Octokit::Client).to receive_message_chain(:new, :create_pull_request).and_raise(Octokit::UnprocessableEntity)
      end

      it 'should not raise Octokit::UnprocessableEntity error' do
        expect {
          Rake::Task['tachikoma:pull_request'].invoke
        }.to_not raise_error
      end
    end
  end
end
