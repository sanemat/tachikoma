require 'spec_helper'
require 'rake'
require 'tachikoma/tasks'

describe 'app.rake' do
  describe 'tachikoma:pull_request' do
    context 'when github returns 422 UnprocessableEntity' do
      before do
        # FIXME: Using `stub_chain` from rspec-mocks' old `:should`
        #        syntax without explicitly enabling the syntax is deprecated.
        #        Use the new `:expect` syntax or explicitly enable `:should`
        #        instead. Called from
        #        /Users/sane/work/ruby-study/tachikoma/spec/tasks/app_task_spec.rb:9:
        #        in `block (4 levels) in <top (required)>'.
        Octokit::Client.stub_chain(:new, :create_pull_request).and_raise(Octokit::UnprocessableEntity)
      end

      it 'should not raise Octokit::UnprocessableEntity error' do
        expect {
          Rake::Task['tachikoma:pull_request'].invoke
        }.to_not raise_error
      end
    end
  end
end
