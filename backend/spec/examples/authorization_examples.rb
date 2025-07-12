RSpec.shared_examples 'an superadmin-only endpoint' do |http_method, action, params_proc = nil|
  let(:endpoint_params) { params_proc ? instance_exec(&params_proc) : {} }

  include_examples 'an signed-only endpoint', http_method, action, params_proc

  context 'when signed in as user' do
    before { sign_in user }

    it 'returns 401 Unauthorized' do
      process action, method: http_method, params: endpoint_params.merge(format: :json)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

RSpec.shared_examples 'an user-only endpoint' do |http_method, action, params_proc = nil|
  let(:endpoint_params) { params_proc ? instance_exec(&params_proc) : {} }
  include_examples 'an signed-only endpoint', http_method, action, params_proc

  context 'when signed in as superadmin' do
    before { sign_in superadmin }

    it 'returns 401 Unauthorized' do
      process action, method: http_method, params: endpoint_params.merge(format: :json)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

RSpec.shared_examples 'an signed-only endpoint' do |http_method, action, params_proc = nil|
  let(:endpoint_params) { params_proc ? instance_exec(&params_proc) : {} }

  context 'when not signed in' do
    it 'returns 401 Unauthorized' do
      process action, method: http_method, params: endpoint_params.merge(format: :json)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end