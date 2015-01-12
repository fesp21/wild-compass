class Brand < ActiveRecord::Base

  has_many :strains

  def to_s
    "#{ name.titleize unless name.nil? }"
  end
end