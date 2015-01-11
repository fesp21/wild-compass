class LotsController < ApplicationController
  helper_method :sort_column, :sort_direction

  expose(:lot, params: :lot_params) { id_param.nil? ? Lot.new : Lot.find(id_param) }

  expose(:lots) do
    if Lot.column_names.include? sort_column
      Lot.order(sort_column + ' ' + sort_direction)
    else
      Lot.joins(:strain).merge(Strain.order(acronym: sort_direction.to_sym))
    end
  end

  expose(:bag) { Bag.new }
  
  # Create new lot.
  def create 
    self.lot = Lot.new(lot_params)
    
    set_weight #  Set lot weight

    respond_to do |format|
      if lot.save
        format.html { redirect_to lot, notice: 'Lot was successfully created.' }
        format.json { render :show, status: :created, location: lot }
      else
        format.html { render :new }
        format.json { render json: lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # Update lot column.
  def update 
    respond_to do |format|
      if lot.update(lot_params)
        format.html { redirect_to lot, notice: 'Lot was successfully updated.' }
        format.json { render :show, status: :ok, location: lot }
      else
        format.html { render :edit }
        format.json { render json: lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # Destroy lot.
  def destroy 
    lot.destroy
    respond_to do |format|
      format.html { redirect_to lots_url, notice: 'Lot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def lot_params
      params.require(:lot).permit(:name, :weight, :initial_weight, :strain_id, :category, :current_weight)
    end

    def id_param
      params[:id]
    end

    # Set column to sort in order.
    def sort_column
      %w(id name category strain initial_weight current_weight created_at updated_at).include?(params[:sort]) ? params[:sort] : 'updated_at'
    end

    # Set sort direction to ascending or descending.
    def sort_direction
      %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
    end

    # Set lot weight.
    def set_weight 
      lot.weight = lot.weight.to_d
      lot.current_weight = lot.initial_weight = lot.weight
    end
end
