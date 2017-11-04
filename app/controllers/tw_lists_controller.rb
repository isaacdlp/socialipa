class TwListsController < ApplicationController
  before_action :set_tw_list, only: [:show, :edit, :update, :destroy, :clone]
  
  # GET /tw_lists
  # GET /tw_lists.json
  def index
    @tw_lists = TwList.paginate(page: params[:page], per_page: 100).order('name ASC')
  end

  # GET /tw_lists/1
  # GET /tw_lists/1.json
  def show
  end

  # GET /tw_lists/new
  def new
    @tw_list = TwList.new
  end

  # GET /tw_lists/1/edit
  def edit
  end

  # POST /tw_lists
  # POST /tw_lists.json
  def create
    @tw_list = TwList.new(tw_list_params)

    respond_to do |format|
      if @tw_list.save
        format.html { redirect_to @tw_list, notice: 'The List was successfully created.' }
        format.json { render :show, status: :created, location: @tw_list }
      else
        format.html { render :new }
        format.json { render json: @tw_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tw_lists/1
  # PATCH/PUT /tw_lists/1.json
  def update
    respond_to do |format|
      if @tw_list.update(tw_list_params)
        format.html { redirect_to @tw_list, notice: 'The List was successfully updated.' }
        format.json { render :show, status: :ok, location: @tw_list }
      else
        format.html { render :edit }
        format.json { render json: @tw_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tw_lists/1
  # DELETE /tw_lists/1.json
  def destroy
    @tw_list.destroy
    respond_to do |format|
      format.html { redirect_to tw_lists_url, notice: 'The List was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  #GET /tw_lists/1/clone
  #POST /tw_lists/1/clone
  def clone 
    @errors = []
    if request.post?
      clone_name = params[:clone_name]
      clone_merge = params[:clone_merge].to_i
      clone_op = params[:clone_op]
      
      dest = nil
      merge = nil
      if clone_name.blank?
        @errors.push "The Clone list name cannot be empty" 
      else 
        dest = TwList.find_by_name(clone_name)  
        unless dest
          dest = TwList.new
          dest[:name] = clone_name
          dest.save
        end
      
        if clone_merge > 0
          merge = TwList.find_by_id(clone_merge)
        end
        
        @tw_list.tw_list_items.all.order('created_at ASC').each do |item|
          if merge
            if clone_op == 'AND'
              unless merge.tw_list_items.find_by_item(item.item)
                next
              end
            elsif clone_op == 'XOR'
              if merge.tw_list_items.find_by_item(item.item)
                next
              end
            end
          end
          
          begin
            dest.tw_list_items.build({item: item.item, created_at: item.created_at}).save
          rescue ActiveRecord::RecordNotUnique
          end
        end
        
        if merge
          merge.tw_list_items.order('created_at ASC').each do |item|
            if clone_op == 'AND'
              next
            elsif clone_op == 'XOR'
              if @tw_list.tw_list_items.find_by_item(item.item)
                next
              end
            end
            
            begin
              dest.tw_list_items.build({item: item.item, created_at: item.created_at}).save
            rescue ActiveRecord::RecordNotUnique
            end
          end
        end
      end
      
      respond_to do |format|
        if @errors.empty?
          format.html { redirect_to dest, notice: 'The List was successfully updated.' }
        else
          format.html { render }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tw_list
      @tw_list = TwList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tw_list_params
      params.require(:tw_list).permit(:name, :description, :position)
    end
end
