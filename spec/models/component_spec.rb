# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Component, type: :model do
  it { is_expected.to belong_to(:project) }
end
