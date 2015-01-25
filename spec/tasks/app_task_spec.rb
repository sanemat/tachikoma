require 'spec_helper'
require 'rake'
require 'tachikoma/tasks'

# FIXME: This is not test against rake task.
describe 'Tachikoma::Aplication' do
  describe '#pull_request' do
    context 'when github returns 422 UnprocessableEntity' do
      before do
        allow(Octokit::Client).to \
          receive_message_chain(:new, :create_pull_request)
          .and_raise(Octokit::UnprocessableEntity)
      end

      it 'should not raise Octokit::UnprocessableEntity error' do
        expect {
          Tachikoma::Application.new.pull_request
        }.to_not raise_error
      end
    end
  end
end
