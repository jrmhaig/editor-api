# frozen_string_literal: true

class ApiController < ActionController::API
  include Identifiable

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound, with: -> { notfound }
    rescue_from CanCan::AccessDenied, with: -> { denied }
  end

  private

  def authorize_user
    head :unauthorized unless current_user
  end

  def notfound
    head :not_found
  end

  def denied
    head :forbidden
  end
end
