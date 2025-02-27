Rails.application.routes.draw do

  # Routes for the Meal resource:

  # CREATE
  post("/insert_meal", { :controller => "meals", :action => "create" })
          
  # READ
  get("/meals", { :controller => "meals", :action => "index" })
  
  get("/meals/:path_id", { :controller => "meals", :action => "show" })
  
  # UPDATE
  
  post("/modify_meal/:path_id", { :controller => "meals", :action => "update" })
  
  # DELETE
  get("/delete_meal/:path_id", { :controller => "meals", :action => "destroy" })

  #------------------------------

  get("/sandbox", { :controller => "pages", :action => "sandbox" })

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  
end
