class OrdersController < ApplicationController
  include Authorizable
  include SetSortable

  # Expose sort_column and sort_direction private methods as helper methods
  # to make them available in views
  helper_method :sort_column, :sort_direction

  # Expose order and orders for views 
  # If no id is specified, a new order is instanciated (not created)
  expose(:order, params: :order_params) { id_param.nil? ? Order.new : Order.find(id_param) }
  
  expose(:orders) { Order.select('DISTINCT(orders.id), orders.*')
                         .search(params[:search])
                         .unfulfilled
                         .sort(sort_column, sort_direction)
                  }

  expose(:jar) { Jar.new }

  expose(:jars) { action_name == 'index' ? Jar.unfulfilled : order.jars }
  expose(:bags) { action_name == 'index' ? Bag.unfulfilled : order.bags }
  expose(:bins) { action_name == 'index' ? Bin.unfulfilled : order.bins }

  expose(:brands) { Brand.all }

  respond_to :html, :xml, :json

  rescue_from Wild::Compass::Product::ProductUnavailable do |e|
    respond_to do |format|
      format.html { redirect_to orders_path, alert: "ProductUnavailable: #{e.message}" }
      format.json { render json: { exception: "ProductUnavailable: #{e.message}" }}
    end
  end

  def show
    respond_with(order) do |format|
      format.html
      format.json { render json: order, include: [ order_lines: { include: [ jars: { include: [ :lot ] } ] } ] }
    end
  end

  def create
    self.order = Order.new(order_params)
    if order.save
      respond_with(order) do |format|
        format.html { redirect_to order, notice: 'Order successfully created.' }
        format.json { render json: order, include: [ order_lines: { include: [ jars: { include: [ :lot ] } ] } ] }
      end
    else
      respond_with(order) do |format|
        format.html { render :new, notice: 'Order not successfully created.' }
        format.json { render json: order, include: [ order_lines: { include: [ jars: { include: [ :lot ] } ] } ] }
      end
    end
  end

  def update 
    order.update(order_params)
    respond_with order do |format|
      format.html { redirect_to order, notice: 'Order successfully updated.' }
      format.json { render json: order, include: [ order_lines: { include: [ jars: { include: [ :lot ] } ] } ] }
    end
  end

  def fulfill
    if request.post?
      @jar = Jar.find(params.require(:order)[:jar])
      @bag = Bag.find(params.require(:order)[:bag])
      @jar.weight = (params.require(:order)[:weight]).to_d

      if Transaction.from( @bag ).to( @jar ).take( @jar.weight ).by( current_user ).commit
        @jar.update(fulfilled: true)
        @bag.save
        @jar.save
      end

    else
      @jar = order.first_unfulfilled
      @bag = @jar.bag
      respond_to do |format|
        format.html
      end
    end
  end

  def destroy 
    order.destroy
    respond_with(order)
  end

  private

    def id_param
      params[:id]
    end

    def order_params
      params.require(:order).permit(:customer, :shipped_at, :ordered_at, :jar, :bag, :weight, :ces_order_id, :created_by, :placed_by,
      order_lines_attributes: [ :id, :brand_id, :jar_id, :quantity ])
    end

    # Set column to sort in order
    def sort_column
      %w(ces_order_id customer total_weight ordered_at shipped_at).include?(params[:sort]) ? params[:sort] : 'ces_order_id'
    end

    # Set sort direction to ascending or descending
    def sort_direction
      %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
    end

end
