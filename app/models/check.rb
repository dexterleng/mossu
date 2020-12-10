class Check < ApplicationRecord
  enum status: { created: 0, queued: 1, active: 2, completed: 3, failed: 4 }
  has_many :submissions
  has_one_attached :report

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
