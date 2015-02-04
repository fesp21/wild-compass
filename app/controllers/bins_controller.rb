class BinsController < ApplicationController

  include FindEncodable

  respond_to :html, :xml, :json

  before_action :authorized?

  helper_method :sort_column, :sort_direction

  expose(:bin, params: :bin_params) { find(Bin) }

  expose(:bins) { Bin.order(sort_column + ' ' + sort_direction) }

  def create
    self.bin = Bin.new(bin_params)
    bin.save
    respond_with(bin)
  end

  def update
    bin.update(bin_params)
    respond_with(bin)
  end

  def destroy
    bin.destroy
    respond_with(bin)
  end

  def label
    respond_to do |format|
      format.html
    end
  end



  private

    # Set column to sort in order.
    def sort_column
      %w(id name).include?(params[:sort]) ? params[:sort] : 'name'
    end

    # Set sort direction to ascending or descending.
    def sort_direction
      %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def authorized?
      authorize! action_name.to_sym, Bin
    end

    def id_param
      params[:id]
    end

    def bin_params
      params.require(:bin).permit(:name, :location_id)
    end
end
