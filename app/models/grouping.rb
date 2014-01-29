class Grouping < ActiveRecord::Base
  has_many :wats_groupings
  has_many :new_wats, ->(grouping) { grouping.last_emailed_at.present? ? where('wats.created_at > ?', grouping.last_emailed_at) : self }, class_name: "Wat", through: :wats_groupings, source: :wat
  has_many :wats, through: :wats_groupings
  has_many :notes

  state_machine :state, initial: :active do
    state :active, :resolved, :acknowledged

    event :activate do
      transition [:resolved, :acknowledged] => :active
    end

    event :resolve do
      transition [:acknowledged, :active] => :resolved
    end

    event :acknowledge do
      transition :active => :acknowledged
    end
  end

  scope :open,          -> {where(state: [:acknowledged, :active])}
  scope :active,        -> {where(state: :active)}
  scope :resolved,      -> {where(state: :resolved)}
  scope :acknowledged,  -> {where(state: :acknowledged)}
  scope :state,         -> (state) {where(state: state)}
  scope :matching, ->(wat) {language(wat.language).where(wat.matching_selector)}
  scope :filtered, ->(opts=nil) {
    opts ||= {}

    running_scope = opts[:state] ? state(opts[:state]) : open
    running_scope = running_scope.app_name(opts[:app_name]) if opts[:app_name]
    running_scope = running_scope.app_env(opts[:app_env])   if opts[:app_env]
    running_scope = running_scope.language(opts[:language]) if opts[:language]

    running_scope.distinct('groupings.id')
  }

  scope( :wat_order, -> { reorder("latest_wat_at asc") } ) do
    def reverse
      reorder("latest_wat_at desc")
    end
  end

  scope :app_env,  -> (ae) { distinct('groupings.id').joins(:wats).references(:wats).where('wats.app_env IN (?)', ae) }
  scope :app_name, -> (an) { distinct('groupings.id').joins(:wats).references(:wats).where('wats.app_name IN (?)', an) }
  scope :language, -> (an) { distinct('groupings.id').joins(:wats).references(:wats).where('wats.language IN (?)', an) }

  def open?
    acknowledged? || active?
  end

  def app_envs
    wats.select(:app_env).uniq.map &:app_env
  end

  def is_javascript?
    wats.javascript.any?
  end

  def app_user_stats(filters: {}, key_name: :id, limit: nil)
    wats.filtered(filters)
      .select("app_user -> '#{key_name}' as #{key_name}, count(*) as count")
      .group("app_user -> '#{key_name}'")
      .order("count(app_user -> '#{key_name}') desc")
      .limit(limit).count
  end

  def app_user_count(filters: {}, key_name: :id)
    wats.filtered(filters).distinct_users.count
  end

  def self.get_or_create_from_wat!(wat)
    transaction do
      open.matching(wat).first_or_create(state: "active")
    end
  end

  def chart_data(filters
)
    wat_chart_data = wats.filtered(filters).group('date_trunc(\'day\',  wats.created_at)').count.inject({}) do |doc, values|
      doc[values[0]] = values[1]
      doc
    end
    return [] if wat_chart_data.empty?
    start_time = wat_chart_data.keys.min
    end_time   = wat_chart_data.keys.max

    wat_chart_values = []
    while start_time <= end_time
      wat_chart_values << [start_time.to_i*1000, wat_chart_data[start_time] || 0]

      start_time = start_time.advance(days: 1)
    end
    wat_chart_values
  end

  def self.epoch
    Wat.order(:id).first.created_at || Date.new(2015, 10, 1).to_time
  end

  def self.rescore
    Grouping.find_each do |grouping|
      grouping.rescore!
    end
  end

  def rescore!
    transaction do
      self.popularity = nil
      self.wats.where("wats_groupings.state != ?", :resolved).find_each do |wat|
        self.upvote wat.created_at
      end
      self.save!
    end
  end

  def popularity_addin(effective_time=nil)
    0.1 * (2 ** ((effective_time.to_i - Grouping.epoch.to_i) / 1.day.to_i))
  end

  def update_sorting(effective_time=nil)
    effective_time = Time.zone.now unless effective_time
    self.popularity = 0.1 unless self.popularity

    self.popularity += popularity_addin(effective_time)
    self.latest_wat_at = effective_time
  end
end
