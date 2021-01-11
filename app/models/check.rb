class Check < ApplicationRecord
  enum status: { created: 0, queued: 1, active: 2, completed: 3, failed: 4 }
  has_many :submissions
  belongs_to :user
  has_one_attached :report
  has_one_attached :unanonymized_report
  has_one_attached :base_submission

  validate :base_submission_is_a_zip
  validate :base_submission_max_size

  def base_submission_is_a_zip
    if base_submission.attached? && base_submission.content_type != 'application/zip'
      errors.add(:base_submission, 'Base submission must be a zip')
    end
  end

  def base_submission_max_size
    max_bytes = 5 * 1000 * 1000
    if base_submission.attached? && base_submission.blob.byte_size > max_bytes
      errors.add(:base_submission, 'Base submission cannot exceed 5 MB')
    end
  end

  def can_start?
    created? && submissions.count >= 2
  end

  def report_exists?
    report.attached?
  end

  def unanonymized_report_exists?
    unanonymized_report.attached?
  end

  def transition_to_queued
    update!(status: :queued)
  end

  def transition_to_active
    update!(status: :active)
  end

  def transition_to_completed
    update!(status: :completed)
  end

  def transition_to_failed
    update!(status: :failed)
  end
end
