class RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :new]
  before_action :is_my_recipe!, only: [:edit, :update]
  autocomplete :ingredient, :name, :display_value => :funky_method

  def index
    recipe = Recipe.new
    
    unless params[:ingredient].to_s.empty? 

      selected_ingredients = recipe.translate_input_ingredients_into_database_ingredients_ids(params[:ingredient])
      @recipes = recipe.find_recipes_associated_with_ingredients(selected_ingredients)
    else
      @recipes = all_recipes_displayable
    end

    @menu_recipe = MenuRecipe.new
  end
    
  def show
    @recipe = Recipe.find(params[:id])
    @comments = Comment.where(recipe_id: @recipe.id)
    @comment = Comment.new
    @compositions = Composition.where(recipe_id: @recipe.id)
  end 

  def new 
    @recipe = Recipe.new
    @recipe_categories = RecipeCategory.all
    @ingredients = Ingredient.all
    @price_indicators = ["€", "€ €", "€ € €", "€ € € €", "€ € € € €"]
  end

  def create
    @recipe = Recipe.new(
      name: params[:name], 
      description: params[:description], 
      recipe_category_id: params[:recipe_category].to_i,
      price_indicator: params[:price_indicator].to_i, 
      cooking_time: params[:cooking_time], 
      preparation_time: params[:preparation_time], 
      user_id: current_user.id)
      ingredients_ids = params[:ingredient_ids]

    if @recipe.save
        @recipe.picture.attach(params[:picture])
        ingredients_ids.each do |ingredient_id|
          params[:quantities].each do |key, value|
            if ingredient_id == key 
              composition = Composition.new(recipe_id: @recipe.id, ingredient_id: ingredient_id.to_i, quantity: value.to_i)
              composition.save 
            end
          end
        end
      flash[:success] = "Ta recette a bien été sauvegardée !"

      redirect_to recipe_path(@recipe.id)
    else 
      flash[:error] = "Désolé, ta recette n'a pas été sauvegardée !"

      redirect_to new_recipe_path
    end
  end

    
  def edit
    @recipe = Recipe.find(params[:id])
    @recipe_categories = []
    RecipeCategory.all.each do |recipe|
      @recipe_categories << [recipe.name, recipe.id]
    end
    @price_indicators = [["€", 1], ["€ €", 2], ["€ € €", 3], ["€ € € €", 4], ["€ € € € €",5]]
  end 

  def update
    @recipe = Recipe.find(params[:id])
    @recipe.update(update_params)
    
    redirect_to recipe_path(@recipe)
  end

  def destroy
    @recipe = Recipe.where(user_id: params[:id])
    @recipe.user_id = 2
  end
  
  private

  def post_params
    params.require(:recipe).permit(:ingredient, :picture)
  end

  def included_in?(array)
    array.to_set.superset?(self.to_set)
  end

  def update_params
    params[:recipe].permit(:name, :recipe_category, :price_indicator, :preparation_time, :cooking_time, :description)
  end

  def is_my_recipe!
    if Recipe.find(params[:id]).user_id != current_user.id
      flash[:error]= "On ne modifie pas ce qui ne nous appartient pas !"

      redirect_to root_path
    end
  end

end