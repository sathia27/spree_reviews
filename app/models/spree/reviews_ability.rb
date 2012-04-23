class Spree::ReviewsAbility
  include CanCan::Ability

  def initialize(user)
    can :create, Spree::Review do |review, product|
      (user.has_role?(:user) || !Spree::Reviews::Config[:require_login]) and user.orders.where(:status => "complete").line_items.pluck(:variant_id).include?(Spree::Variant.find_by_product_id(@product.id).id
    end
    can :create, Spree::FeedbackReview do |review|
      user.has_role?(:user) || !Spree::Reviews::Config[:require_login]
    end
  end
end
