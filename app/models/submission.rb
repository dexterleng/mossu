class Submission < ApplicationRecord
  has_one_attached :zip_file
  belongs_to :check

  validate :check_zip_file_presence

  def check_zip_file_presence
    errors.add(:zip_file, 'cannot be missing') unless zip_file.attached?
  end
end
