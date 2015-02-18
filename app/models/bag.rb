class Bag < ActiveRecord::Base

  include Weightable
  include Accountable
  include Storyable
  include Searchable
  include Encodable
  include Recallable
  include Quarantineable
  include Sortable
  include Filterable

  after_save -> { lot.bag_changed }


  
  def update_category_and_strain
    self[:category] = category.titleize
    self[:strain] = strain.acronym.upcase
    save
  end

  scope :by_strains,       -> (strain = nil) { joins(:plants).merge(Plant.where(strain: strain)) }
  scope :by_categories,    -> (category = nil) { joins(:container).merge(Container.where(category: category)) }
  scope :by_trims,         -> { by_categories 'Trim' }
  scope :by_buds,          -> { by_categories 'Buds' }
  scope :by_brands,        -> (brand = nil) { joins(:strains).merge(Strain.where(brand: brand)) }

  scope :fulfilled,   -> { uniq.joins(:jars).merge( Jar.fulfilled   )}
  scope :unfulfilled, -> { uniq.joins(:jars).merge( Jar.unfulfilled )}

  scope :tested,   -> { where tested: true }
  scope :archived, -> { where archived: true }

  def self.first_available(brand, weight)
    by_brands(brand).by_buds.where(current_weight: weight..Float::INFINITY, sent_to_lab: false, tested: false, archived: false).first
  end

  def update_variance
    bags = Bag.where(tested: false, sent_to_lab: false)
    mean = bags.sum(:current_weight) / bags.count

    update(variance: Math.sqrt((current_weight - mean)**2))
  end

  def update_delta
    update(delta: initial_weight - current_weight)
  end

  def update_delta_old
    if history.history_lines.reweight[-1].nil?
      first = 0.0
    else
      first = history.history_lines.reweight[-1].quantity
    end

    if history.history_lines.reweight[-2].nil?
      last = 0.0
    else
      last = history.history_lines.reweight[-2].quantity
    end

    update(delta_old: first - last)
  end



  belongs_to :lot

  belongs_to :container

  belongs_to :bin

  belongs_to :status, class_name: 'Bags::Status', foreign_key: 'bags_status_id'

  has_many :jars, -> { uniq }

  has_many :plants, -> { uniq }, through: :container

  has_many :strains, -> { uniq }, through: :plants

  has_many :brands, -> { uniq }, through: :strains

  

  delegate :category, to: :container, prefix: false, allow_nil: true

  has_one :location, through: :bin
  


  def to_s
    "#{ name.upcase unless name.nil? }"
  end

  def location
    bag.bin.location
  end

  def strain
    strains.first
  rescue
    ''
  end

  def jar
    jars.first
  rescue
    ''
  end

  def plant
    plants.first
  rescue
    ''
  end

  def brand
    brands.first
  rescue
    ''
  end

  def category
    container.category
  rescue
    ''
  end

end
