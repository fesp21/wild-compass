class Transaction
  def self.from(source)
    Transaction.new(source)
  end

  def to(target)
    @target = target
    self
  end

  def take(quantity)
    @quantity = quantity
    self
  end

  def commit(opts = nil)
    raise "source is nil" if @source.nil?
    raise "target is nil" if @target.nil?
    raise "quantity is nil or zero" if @quantity.nil? || @quantity.to_d == 0.0

    if opts[:initial]
      @source.decrease_current_weight(@quantity.to_d)

      @source.history.add_line(@source, @target, @quantity, :decrease_current_weight)
      @target.history.add_line(@target, @source, @quantity, :increase_current_weight)
    else
      @source.decrease_current_weight(@quantity.to_d)
      @target.increase_current_weight(@quantity.to_d)
    
      @source.history.add_line(@source, @target, @quantity, :decrease_current_weight)
      @target.history.add_line(@target, @source, @quantity, :increase_current_weight)
    end

    true
  end

  private

    def initialize(source)
      @source = source
    end

end