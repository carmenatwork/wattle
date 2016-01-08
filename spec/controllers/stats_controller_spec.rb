require 'spec_helper'

describe StatsController, :type => :controller do
  describe "GET #index" do
    subject { get :index }
    context 'when logged in' do
      before do
        login watchers(:default)
      end

      it {should be_success}
    end
  end
end
