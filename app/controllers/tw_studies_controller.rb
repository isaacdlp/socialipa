class TwStudiesController < ApplicationController
  before_action :set_tw_study, only: [:show, :edit, :update, :destroy]

  # GET /tw_studies
  # GET /tw_studies.json
  def index
    @tw_studies = TwStudy.all
  end

  # GET /tw_studies/1
  # GET /tw_studies/1.json
  def show
  end

  # GET /tw_studies/new
  def new
    @tw_study = TwStudy.new
  end

  # GET /tw_studies/1/edit
  def edit
  end

  # POST /tw_studies
  # POST /tw_studies.json
  def create
    @tw_study = TwStudy.new(tw_study_params)

    respond_to do |format|
      if @tw_study.save
        format.html { redirect_to @tw_study, notice: 'Tw study was successfully created.' }
        format.json { render :show, status: :created, location: @tw_study }
      else
        format.html { render :new }
        format.json { render json: @tw_study.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_studies/1
  # PATCH/PUT /tw_studies/1.json
  def update
    respond_to do |format|
      if @tw_study.update(tw_study_params)
        format.html { redirect_to @tw_study, notice: 'Tw study was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_study }
      else
        format.html { render :edit }
        format.json { render json: @tw_study.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_studies/1
  # DELETE /tw_studies/1.json
  def destroy
    @tw_study.destroy
    respond_to do |format|
      format.html { redirect_to tw_studies_url, notice: 'Tw study was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_study
      @tw_study = TwStudy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_study_params
      params.require(:tw_study).permit(:name)
    end
end
