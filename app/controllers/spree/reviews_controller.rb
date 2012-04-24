class Spree::ReviewsController < Spree::BaseController
  helper Spree::BaseHelper
  before_filter :load_product, :only => [:index, :new, :create]
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  def index
    @approved_reviews = Spree::Review.approved.find_all_by_product_id(@product.id)
  end

  def new
    if current_user
      order_ids = current_user.orders.where(:state => "completed").pluck(:id)
      can_write_review = Spree::LineItem.where(order_ids).pluck(:variant_id).include?(Spree::Variant.find_by_product_id(@product.id).id)
    end
    redirect_to products_path and return if !can_write_review or !current_user
    @review = Spree::Review.new(:product => @product)
    authorize! :new, @review
  end

  # save if all ok
  def create
    if current_user
      order_ids = current_user.orders.where(:state => "completed").pluck(:id)
      can_write_review = Spree::LineItem.where(order_ids).pluck(:variant_id).include?(Spree::Variant.find_by_product_id(@product.id).id)
    end
    redirect_to products_path and return if !can_write_review or !current_user
    params[:review][:rating].sub!(/\s*stars/,'') unless params[:review][:rating].blank?
    @review = Spree::Review.new(params[:review])
    @review.product = @product
    @review.user = current_user if user_signed_in?
    @review.ip_address = request.remote_ip

    authorize! :create, @review

    if @review.save
      flash[:notice] = t('review_successfully_submitted')
      redirect_to (product_path(@product))
    else
      render :action => "new"
    end
  end

  def terms
  end

  private

    def load_product
      @product = Spree::Product.find_by_permalink!(params[:product_id])
    end

end
