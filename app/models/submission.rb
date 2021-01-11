class Submission < ApplicationRecord
  has_one_attached :zip_file
  belongs_to :check

  validate :zip_file_is_present

  def zip_file_is_present
    unless zip_file.attached?
      errors.add(:zip_file, 'cannot be missing')
      return
    end
    error.add(:zip_file, 'must be zip') unless zip_file.content_type == 'application/zip'
  end
end
