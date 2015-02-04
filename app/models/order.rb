class Order < ActiveRecord::Base

  include Searchable

  scope :fulfilled,   -> {  select('orders.*')
                           .joins(:order_lines)
                           .merge( OrderLine.joins(:jars)
                                            .merge( Jar.where(fulfilled: true)
                                                       .order(id: :asc)
                         )).uniq }

  scope :unfulfilled, -> {  select('orders.*')
                           .joins(:order_lines)
                           .merge( OrderLine.joins(:jars)
                                            .merge( Jar.where(fulfilled: false )
                                                       .order(id: :asc)
                         )).uniq }

  def first_unfulfilled
    order_lines.each do |line|
      line.jars.each do |jar|
        return jar if jar.unfulfilled?
      end
    end
    return
  end

  def unfulfilled?
    !fulfilled?
  end

  def fulfilled?
    first_unfulfilled == nil
  end



  ### Order lines

  has_many :order_lines, -> { uniq }
  
  accepts_nested_attributes_for :order_lines,
                                 allow_destroy: true,
                                 reject_if: :all_blank



  ### Customer

  validates :customer, presence: true

  

  ### Total weight

  ## 
  # Computes order's total weight
  def total_weight
    w = 0.0
    order_lines.each do |line|
      w += line.quantity
    end
    w
  end
end
