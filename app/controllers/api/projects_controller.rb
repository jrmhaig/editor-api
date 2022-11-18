# frozen_string_literal: true

module Api
  class ProjectsController < ApiController
    before_action :require_oauth_user, only: %i[update index destroy]
    before_action :load_project, only: %i[show update destroy]
    before_action :load_projects, only: %i[index]
    load_and_authorize_resource
    skip_load_resource only: :create

    def index
      render :index, formats: [:json]
    end

    def show
      render :show, formats: [:json]
    end

    def create
      project_hash = project_params.merge(user_id: current_user)
      result = Project::Operation::Create.call(project_hash:)

      if result.success?
        @project = result[:project]
        render :show, formats: [:json]
      else
        render json: { error: result[:error] }, status: :internal_server_error
      end
    end

    def update
      result = Project::Operation::Update.call(project: @project, params: project_params, user_id: current_user)

      if result.success?
        render :show, formats: [:json]
      else
        render json: { error: result[:error] }, status: :bad_request
      end
    end

    def destroy
      @project.destroy
      head :ok
    end

    private

    def load_project
      @project = Project.find_by!(identifier: params[:id])
    end

    def load_projects
      @projects = Project.where(user_id: current_user)
    end

    def project_params
      params.fetch(:project, {}).permit(
                      :name,
                      :project_type,
                      {
                        image_list: [],
                        components: %i[id name extension content index default]
                      }
                    )
    end
  end
end
