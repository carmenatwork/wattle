class Grouping < ActiveRecord::Base
  has_many :wats_groupings
  has_many :wats, through: :wats_groupings

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

  scope :open,         -> {where(state: [:acknowledged, :active])}
  scope :active,       -> {where(state: :active)}
  scope :resolved,     -> {where(state: :resolved)}
  scope :acknowledged, -> {where(state: :acknowledged)}

  scope( :wat_order, -> { joins(:wats).group(:"groupings.id").reorder("max(wats.id) asc") } ) do
    def reverse
      reorder("max(wats.id) desc")
    end
  end

  scope :app_env,  ->(ae){where('wats.app_env = ?', ae) }

  def open?
    acknowledged? || active?
  end

  def app_envs
    wats.select(:app_env).uniq.map &:app_env
  end

  def self.get_or_create_from_wat!(wat)
    transaction do
      open.where(error_class: wat.error_class, key_line: wat.key_line).first_or_create(state: "active")
    end
  end

end