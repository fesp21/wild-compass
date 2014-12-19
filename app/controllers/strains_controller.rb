class StrainsController < ApplicationController

  expose(:strain, params: :strain_params) { id_param.nil? ? strain.new : strain.find(id_param) }
  expose(:strains) { strain.order(sort_column + ' ' + sort_direction) }
  expose(:lot) { Lot.new }

  def create
    self.strain = Strain.new(strain_params)

    respond_to do |format|
      if self.train.save
        format.html { redirect_to strain, notice: 'Strain was successfully created.' }
        format.json { render :show, status: :created, location: strain }
      else
        format.html { render :new }
        format.json { render json: strain.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if self.strain.update(strain_params)
        format.html { redirect_to strain, notice: 'Strain was successfully updated.' }
        format.json { render :show, status: :ok, location: strain }
      else
        format.html { render :edit }
        format.json { render json: strain.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    self.strain.destroy
    respond_to do |format|
      format.html { redirect_to strains_url, notice: 'Strain was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

 private

    def strain_params
      params.require(:strain).permit(:name, :info, :acronym)
    end

    def id_param
      params[:id]
    end
end