class GroupingNotifier
  include Sidekiq::Worker
  include Debounce

  DEBOUNCE_DELAY = 60.minutes
  SIDEKIQ_NOTIFY_AFTER = 10.minutes

  attr_accessor :grouping

  class << self
    # def notify(grouping_id)
    #   GroupingNotifier.new(Grouping.find(grouping_id)).perform
    # end

    def wat_user(grouping_id)
      {id: "grouping_#{grouping_id}"}
    end
  end

  # def initialize(grouping)
  #   self.grouping = grouping
  # end

  def perform(grouping_id)
    self.grouping = Grouping.find(grouping_id)

    grouping.with_lock do
      return unless needs_notifying?
      send_email
      mark_as_sent
    end
  end

  def send_email_now?
    grouping.unacknowledged? && (grouping.last_emailed_at.nil? ||  (grouping.last_emailed_at <= Time.zone.now - DEBOUNCE_DELAY))
  end

  def wats
    grouping.wats
  end

  def needs_notifying?
    return false if sidekiq_and_too_new?
    return false if grouping.app_envs.include? 'honeypot'
    return false if grouping.is_javascript? && js_wats_per_hour_in_previous_weeks > js_wats_in_previous_day / 2
    return false if grouping.acknowledged? && similar_wats_per_hour_in_previous_weeks > similar_wats_in_previous_day / 2
    (grouping.unacknowledged? || grouping.acknowledged?) && (grouping.last_emailed_at.nil? || grouping.wats.where("wats.created_at > ?", grouping.last_emailed_at).any?)
  end

  def similar_wats_per_hour_in_previous_weeks()
    Wat.language(grouping.language).open.after(24.day.ago).count / 24
  end

  def similar_wats_in_previous_day()
    Wat.language(grouping.language).open.after(1.day.ago).count
  end

  def js_wats_per_hour_in_previous_weeks
    Wat.javascript.open.after(24.day.ago).count / 24
  end

  def js_wats_in_previous_day
    Wat.javascript.open.after(1.day.ago).count
  end

  def send_email
    Rails.logger.info("Sending email for grouping #{grouping.id}")
    grouping.email_recipients.each do |watcher|
      GroupingMailer.notify(watcher, grouping).deliver_now
    end
  end

  private

  def mark_as_sent
    grouping.update_attributes!(last_emailed_at: Time.zone.now)
  end

  def sidekiq_job?
    sidekiq_msg.present?
  end

  def sidekiq_msg
    wats.order(:captured_at).last.sidekiq_msg
  end

  def sidekiq_and_too_new?
    return false unless sidekiq_job?
    return false if sidekiq_msg["retry"] == false
    return false if sidekiq_msg["retry"] == "false"
    if (sidekiq_msg["retry"] != "true" && sidekiq_msg["retry"] != true)
      return false if sidekiq_msg["retry"].to_s.to_i == 0
    end
    notify_after = (sidekiq_msg["notify_after"] || SIDEKIQ_NOTIFY_AFTER).to_i
    enqueued_at = sidekiq_msg["enqueued_at"].to_f

    return Time.zone.now < Time.at(enqueued_at + notify_after)
  end
end
