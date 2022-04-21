# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../lib/operation_response'

RSpec.describe 'Create project requests', type: :request do
  let(:user_id) { 'e0675b6c-dc48-4cd6-8c04-0f7ac05af51a' }
  let(:project) { create(:project, user_id: user_id) }

  describe 'create' do
    context 'when auth is correct' do
      before do
        mock_oauth_user(user_id)

        response = OperationResponse.new
        response[:project] = project
        allow(Project::Operation::Create).to receive(:call).and_return(response)
      end

      it 'returns success' do
        post '/api/projects'
        expect(response.status).to eq(200)
      end
    end

    context 'when creating project fails' do
      before do
        mock_oauth_user(user_id)

        response = OperationResponse.new
        response[:error] = 'Error creating project'
        allow(Project::Operation::Create).to receive(:call).and_return(response)
      end

      it 'returns error' do
        post '/api/projects'
        expect(response.status).to eq(500)
      end
    end

    context 'when no auth user' do
      it 'returns unauthorized' do
        post '/api/projects'
        expect(response.status).to eq(401)
      end
    end
  end
end
