class Submission < ApplicationRecord
  has_one_attached :zip_file
  belongs_to :check

  validate :zip_file_is_present, :zip_file_max_size

  def zip_file_is_present
    unless zip_file.attached?
      errors.add(:zip_file, 'cannot be missing')
      return
    end
    error.add(:zip_file, 'must be zip') unless zip_file.content_type == 'application/zip'
  end

  def zip_file_max_size
    max_bytes = 20 * 1000 * 1000
    if zip_file.attached? && zip_file.blob.byte_size > max_bytes
      errors.add(:zip_file, 'Submission cannot exceed 20 MB')
    end
  end
end
