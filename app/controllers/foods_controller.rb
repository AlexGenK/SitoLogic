class FoodsController < ApplicationController
  def index
    @pagy, @foods = pagy(:offset, Food.order(:name_ukr, :code), limit: 15)
  end
end
