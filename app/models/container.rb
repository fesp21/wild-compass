class Container < ActiveRecord::Base

  include Weightable
  include Accountable
  include Storyable



  scope :trims,   -> { joins(:lots).merge(Lot.where(category: 'Trim')) }  
  scope :buds,    -> { joins(:lots).merge(Lot.where(category: 'Buds')) }
  scope :strains, -> (strain = nil) { joins(:plants).merge(Plant.where(strain: strain)) }
  scope :categories, -> (category = nil) { joins(:lots).merge(Lot.where(category: category)) }



  has_and_belongs_to_many :plants

  accepts_nested_attributes_for :plants

	has_and_belongs_to_many :lots

  has_many :bags, through: :lots

  has_many :jars, through: :lots	



  has_many :strains, through: :lots



  def to_s
    name.upcase
  rescue
    ''
  end



  def category
    lots.map(&:category).uniq.first
  rescue
    ''
  end

  def lot
    lots.first
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

  alias_method :real_strains, :strains

  def strain
    lots.map(&:strains).uniq.first
  rescue
    ''
  end

  def strains
    self.real_strains
  rescue
    ''
  end

end
