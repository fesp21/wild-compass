class API::V1::OrdersController < API::V1::APIController
  respond_to :json

  def index
    respond_with Order.all
  end

  def show
    respond_with Order.find(id_param)
  end

  def create
    respond_with Order.create(order_params)
  end

  def update
    respond_with Order.update(order_params)
  end

  def destroy
    respond_with Order.destroy(id_param)
  end

  private
    
    def order_params
      params.require(:order).permit(:customer, :shipped_at, :ordered_at, order_lines_attributes: [ :product_type, :product_id, :quantity ])
    end

    def id_param
      params[:id]
    end

end