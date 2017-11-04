class TwStatsController < ApplicationController
  before_action :set_tw_stat, only: [:show, :edit, :update, :destroy]

  # GET /tw_stats
  # GET /tw_stats.json
  def index
    @tw_stats = TwStat.all
  end

  # GET /tw_stats/1
  # GET /tw_stats/1.json
  def show
  end

  # GET /tw_stats/new
  def new
    @tw_stat = TwStat.new
    @tw_stat.tw_study_id = params[:tw_study_id]
  end

  # GET /tw_stats/1/edit
  def edit
  end

  # POST /tw_stats
  # POST /tw_stats.json
  def create
    @tw_stat = TwStat.new(tw_stat_params)

    respond_to do |format|
      if @tw_stat.save
        format.html { redirect_to @tw_stat, notice: 'Tw stat was successfully created.' }
        format.json { render :show, status: :created, location: @tw_stat }
      else
        format.html { render :new }
        format.json { render json: @tw_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_stats/1
  # PATCH/PUT /tw_stats/1.json
  def update
    respond_to do |format|
      if @tw_stat.update(tw_stat_params)
        format.html { redirect_to @tw_stat, notice: 'Tw stat was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_stat }
      else
        format.html { render :edit }
        format.json { render json: @tw_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_stats/1
  # DELETE /tw_stats/1.json
  def destroy
    @tw_stat.destroy
    respond_to do |format|
      format.html { redirect_to tw_stats_url, notice: 'Tw stat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_stat
      @tw_stat = TwStat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_stat_params
      params.require(:tw_stat).permit(:tw_study_id, :concept, :value)
    end
end
