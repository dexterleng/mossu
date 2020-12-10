class Submission < ApplicationRecord
  has_one_attached :submission_zip
  belongs_to :check
end
