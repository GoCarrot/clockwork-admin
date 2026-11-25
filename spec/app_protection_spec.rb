require 'spec_helper'

# A host app (carrot, parsnip) authenticates a request before it reaches Clockwork::Admin::App, so a cross-origin
# request has to be refused here.
describe Clockwork::Admin::App do
  # Behind a load balancer the request is http to the instance with X-Forwarded-Proto: https.
  let(:headers) { { 'HTTP_X_FORWARDED_PROTO' => 'https', 'HTTP_HOST' => 'admin.test', 'CONTENT_TYPE' => 'application/json' } }
  let(:body) { '{"paused":true}' }
  let(:event) { instance_double(Clockwork::Admin::Event, 'paused=': nil, save!: nil, to_json: '{}') }

  let(:app) do
    klass = Class.new(described_class)
    klass.set :environment, :production
    klass.set :raise_errors, true
    klass.set :show_exceptions, false
    klass.set :zk_cluster, 'zk.test:2181'
    klass.set :zk_lock_name, 'test'
    klass
  end

  before do
    allow(::ZK).to receive(:new).and_return(instance_double(ZK::Client::Threaded, close: nil))
    allow(Clockwork::Admin::Event).to receive(:find).and_return(event)
    allow(Clockwork::Admin::Event).to receive(:all).and_return([])
  end

  context 'with a cross-origin POST' do
    before { post '/events/some_job', body, headers.merge('HTTP_ORIGIN' => 'https://evil.test') }

    it('is rejected with 403') { expect(last_response.status).to eq(403) }
    it('does not touch the event') { expect(event).not_to have_received(:save!) }
  end

  context 'with a same-origin POST behind a load balancer' do
    before { post '/events/some_job', body, headers.merge('HTTP_ORIGIN' => 'https://admin.test') }

    it('is accepted') { expect(last_response.status).to eq(200) }
    it('saves the event') { expect(event).to have_received(:save!) }
  end

  it 'accepts a POST with no Origin header' do
    post '/events/some_job', body, headers

    expect(last_response.status).to eq(200)
  end

  it 'serves a same-origin GET of the event list' do
    get '/events', {}, headers.merge('HTTP_REFERER' => 'https://admin.test/')

    expect(last_response.status).to eq(200)
  end

  it 'reads a request body whose input cannot be rewound' do
    one_shot = StringIO.new(body)
    def one_shot.rewind
      raise 'input is not rewindable'
    end

    post '/events/some_job', nil, headers.merge('rack.input' => one_shot, 'CONTENT_LENGTH' => body.bytesize.to_s)

    expect(last_response.status).to eq(200)
  end
end
