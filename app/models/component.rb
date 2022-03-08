# frozen_string_literal: true

class Component < ApplicationRecord
  belongs_to :project
  validates :name, presence: true
  validates :extension, presence: true
  validates :index, uniqueness: { scope: :project_id }
end
