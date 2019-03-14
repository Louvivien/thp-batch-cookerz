class MenuRecipesController < ApplicationController
 
  def create
    puts '$' * 60
    puts params.inspect
    menu_recipe = MenuRecipe.new(recipe_id: params[:recipe_id], menu_id: params[:menu_id])
    
    if menu_recipe.save
      puts "La recette a bien été ajoutée à ton menu !"
    else
      puts "Désolé, la recette n'a pas été ajoutée !"
    end
  end
end