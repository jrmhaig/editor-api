# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :project, Types::ProjectType, 'Find a project by identifier' do
      argument :identifier, String, required: true, description: 'Project identifier'
    end

    field :projects, Types::ProjectType.connection_type, 'All viewable projects' do
      argument :user_id, String, required: false, description: 'Filter by user ID'
    end

    def project(identifier:)
      Project.find_by(identifier:)
    end

    def projects(user_id: nil, page: 1)
      results = Project.accessible_by(context[:current_ability], :show).order(updated_at: :desc)
      results = results.where(user_id: user_id) if user_id

      results
    end
  end
end
