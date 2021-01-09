class Check < ApplicationRecord
  enum status: { created: 0, queued: 1, active: 2, completed: 3, failed: 4 }
  has_many :submissions
  belongs_to :user
  has_one_attached :report
  has_one_attached :unanonymized_report

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
