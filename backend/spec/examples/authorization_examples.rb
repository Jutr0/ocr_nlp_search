RSpec.shared_examples 'a superadmin-only endpoint' do |method:, path:, params_proc: nil, path_proc: nil|
  include_examples 'a signed-only endpoint', method:, path:, params_proc:, path_proc: path_proc

  context 'when signed in as user' do
    before { sign_in user }

    it 'returns 401 Unauthorized' do
      send(method, endpoint_path, params: endpoint_params, headers: headers)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

RSpec.shared_examples 'an user-only endpoint' do |method:, path:, params_proc: nil, path_proc: nil|
  include_examples 'a signed-only endpoint', method:, path:, params_proc:, path_proc: path_proc

  context 'when signed in as superadmin' do
    before { sign_in superadmin }

    it 'returns 401 Unauthorized' do
      send(method, endpoint_path, params: endpoint_params, headers: headers)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

RSpec.shared_examples 'a signed-only endpoint' do |method:, path:, params_proc: nil, path_proc: nil|
  let(:endpoint_path) { path_proc ? instance_exec(&path_proc) : path }
  let(:endpoint_params) { params_proc ? instance_exec(&params_proc) : {} }

  context 'when not signed in' do
    it 'returns 401 Unauthorized' do
      send(method, endpoint_path, params: endpoint_params, headers: headers)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
