class SeedsController < ApplicationController
  include Authorizable
  include SetWeightable

  respond_to :html

  helper_method :sort_column, :sort_direction

  expose(:seed, params: :seed_params) { params[:id].nil? ? Seed.new : Seed.find(params[:id]) }

  expose(:seeds) do
    if sort_column == 'name'
      Seed.search(params[:search]).sort_by('LENGTH(name), name ' + sort_direction).page(params[:page])
    elsif Seed.column_names.include? sort_column
      Seed.search(params[:search]).order( sort_column + ' ' + sort_direction ).page(params[:page])
    end
  end

  def create
    self.seed = Seed.new(seed_params)
    seed.save
    respond_with(seed)
  end

  def update
    seed.update(seed_params)
    respond_with(seed)
  end

  def destroy
    seed.destroy
    respond_with(seed)
  end

  def reweight
    if request.post?

      seed.weight      = seed_params[:weight].to_d
      seed.message     = seed_params[:message]
      seed.quantity    = seed_params[:weight].to_d

      if Transaction.reweight(seed)
                    .weight(seed.weight)
                    .by(current_user)
                    .because(seed.message)
                    .commit

        redirect_to seed, notice: 'Seed was successfully reweighted.'
      else
        redirect_to seed, notice: 'Seed was not successfully reweighted.'
      end

    else
      respond_to do |format|
        format.html
      end
    end
  end

  def datamatrix
    send_data seed.datamatrix, type: 'image/png', disposition: 'attachment'
  end

  def label
    respond_to do |format|
      format.html
    end
  end

  private

    def seed_params
      params.require(:seed).permit(:name, :stock, :weight, :message, :initial_weight, :current_weight)
    end

    # Set column to sort in order.
    def sort_column
      %w(id name initial_weight current_weight created_at updated_at).include?(params[:sort]) ? params[:sort] : 'created_at'
    end

    # Set sort direction to ascending or descending.
    def sort_direction
      %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
    end

end
