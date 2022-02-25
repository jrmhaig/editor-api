# frozen_string_literal: true

module Api
  module Projects
    class RemixesController < ApiController
      def create
        result = Project::Operation::CreateRemix.call(params)

        if result.success?
          @project = result[:project]
          render '/api/projects/show', formats: [:json]
        else
          render json: { error: result[:error] }, status: :bad_request
        end
      end

      private

      def remix_params
        params.permit(:phrase_id, remix: [:user_id])
      end
    end
  end
end
