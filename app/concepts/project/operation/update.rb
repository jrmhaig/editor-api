# frozen_string_literal: true

require 'operation_response'

class Project
  module Operation
    class Update
      class << self
        def call(params:, project:)
          response = setup_response(project)

          setup_deletions(response, params)
          update_project_attributes(response, params)
          update_component_attributes(response, params)
          persist_changes(response)
          response
        rescue StandardError => e
          Sentry.capture_exception(e)
          response[:error] ||= 'Error persisting changes'
          response
        end

        private

        def setup_response(project)
          response = OperationResponse.new
          response[:project] = project
          response
        end

        def setup_deletions(response, params)
          existing_component_ids = response[:project].components.pluck(:id)
          updated_component_ids = params[:components].pluck(:id)
          response[:component_ids_to_delete] = existing_component_ids - updated_component_ids

          validate_deletions(response)
        end

        def validate_deletions(response)
          default_component_id = response[:project].components.find_by(default: true)&.id
          return unless response[:component_ids_to_delete]&.include?(default_component_id)

          response[:error] = I18n.t 'errors.project.editing.delete_default_component'
        end

        def update_project_attributes(response, params)
          return if response.failure?

          response[:project].assign_attributes(params.slice(:name))
        end

        def update_component_attributes(response, params)
          return if response.failure?

          params[:components].each do |component_params|
            if component_params[:id].present?
              component = response[:project].components.select { |c| c.id == component_params[:id] }.first
              component.assign_attributes(component_params)
            else
              response[:project].components.build(component_params)
            end
          end
        end

        def persist_changes(response)
          return if response.failure?

          ActiveRecord::Base.transaction do
            response[:project].save!
            response[:project].components.where(id: response[:component_ids_to_delete]).destroy_all
          end
        end
      end
    end
  end
end
