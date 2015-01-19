class Lot < ActiveRecord::Base

  include Weightable
  include Accountable
  include Storyable



  scope :by_strains,    -> (strain = nil) { joins(:plants).merge(Plant.where(strain: strain)) }
  scope :by_categories, -> (category = nil) { where(category: category) }
  scope :by_trims,      -> { by_categories 'Trim' }
  scope :by_buds,       -> { by_categories 'Buds' }

  

  has_many :strains, through: :plants
  


  has_and_belongs_to_many :containers

  has_many :plants, through: :containers
  
  has_many :bags

  has_many :jars, through: :bags



  def to_s
    "#{ name.upcase unless name.nil? }"
  end

  private

    alias_method :real_strains, :strains

  public

    def container
      containers.first
    rescue
      ''
    end

    def plant
      plants.first
    rescue
      ''
    end

    def bag
      bags.first
    rescue
      ''
    end

    def jar
      jars.first
    rescue
      ''
    end

    def strain
      strains.uniq.first
    rescue
      ''
    end

    def strains
      self.real_strains
    rescue
      ''
    end

end
