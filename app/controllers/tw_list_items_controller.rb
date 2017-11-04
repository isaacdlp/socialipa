class TwListItemsController < ApplicationController
  before_action :set_tw_list_item, only: [:show, :edit, :update, :destroy]
  
  # GET /tw_list_items
  # GET /tw_list_items.json
  def index
    @tw_list_items = TwListItem.paginate(page: params[:page], per_page: 100)
  end

  # GET /tw_list_items/1
  # GET /tw_list_items/1.json
  def show
  end

  # GET /tw_list_items/new
  def new
    @tw_list_item = TwListItem.new
    @tw_list_item.tw_list_id = params[:tw_list_id]
  end

  # GET /tw_list_items/1/edit
  def edit
  end

  # POST /tw_list_items
  # POST /tw_list_items.json
  def create
    @tw_list_item = TwListItem.new(tw_list_item_params)

    respond_to do |format|
      if @tw_list_item.save
        format.html { redirect_to @tw_list_item, notice: 'The Item was successfully created.' }
        format.json { render :show, status: :created, location: @tw_list_item }
      else
        format.html { render :new }
        format.json { render json: @tw_list_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_list_items/1
  # PATCH/PUT /tw_list_items/1.json
  def update
    respond_to do |format|
      if @tw_list_item.update(tw_list_item_params)
        format.html { redirect_to @tw_list_item, notice: 'The Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_list_item }
      else
        format.html { render :edit }
        format.json { render json: @tw_list_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_list_items/1
  # DELETE /tw_list_items/1.json
  def destroy
    @tw_list_item.destroy
    respond_to do |format|
      format.html { redirect_to @tw_list_item.tw_list, notice: 'The Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_list_item
      @tw_list_item = TwListItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_list_item_params
      params.require(:tw_list_item).permit(:tw_list_id, :item)
    end
end
