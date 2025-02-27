class MealsController < ApplicationController
  def index
    matching_meals = Meal.all

    @list_of_meals = matching_meals.order({ :created_at => :desc })

    render({ :template => "meals/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_meals = Meal.where({ :id => the_id })

    @the_meal = matching_meals.at(0)

    render({ :template => "meals/show" })
  end

  def create
    the_meal = Meal.new
    the_meal.description = params.fetch("query_description")

    # Prepare a hash that will become the headers of the request
    request_headers_hash = {
      "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
      "content-type" => "application/json",
    }

    schema_as_string = '{
"name": "nutrition_values",
"strict": true,
"schema": {
"type": "object",
"properties": {
  "fat": {
    "type": "number",
    "description": "The amount of fat in grams."
  },
  "protein": {
    "type": "number",
    "description": "The amount of protein in grams."
  },
  "carbs": {
    "type": "number",
    "description": "The amount of carbohydrates in grams."
  },
  "total_calories": {
    "type": "number",
    "description": "The total calories calculated based on fat, protein, and carbohydrates."
  }
},
"required": [
  "fat",
  "protein",
  "carbs",
  "total_calories"
],
"additionalProperties": false
}
}'

    response_format = JSON.parse("{
  \"type\": \"json_schema\",
  \"json_schema\": #{schema_as_string}
}")

    # output_schema = JSON.parse(schema_as_string)

    # Prepare a hash that will become the body of the request
    request_body_hash = {
      "model" => "gpt-4o",
      "response_format" => response_format,
      "messages" => [
        {
          "role" => "system",
          "content" => "You are an expert nutritionist. The user will describe a meal. Estimate the calories, carbs, fat, and protein.",
        },
        {
          "role" => "user",
          "content" => the_meal.description,
        },
      ],
    }

    # Convert the Hash into a String containing JSON
    request_body_json = JSON.generate(request_body_hash)

    # Make the API call
    raw_response = HTTP.headers(request_headers_hash).post(
      "https://api.openai.com/v1/chat/completions",
      :body => request_body_json,
    ).to_s

    # Parse the response JSON into a Ruby Hash
    @parsed_response = JSON.parse(raw_response)

    content = @parsed_response.fetch("choices").at(0).fetch("message").fetch("content")

    parsed_content = JSON.parse(content)

    the_meal.fat = parsed_content.fetch("fat")
    the_meal.carbs = parsed_content.fetch("carbs")
    the_meal.protein = parsed_content.fetch("protein")
    the_meal.total_calories = parsed_content.fetch("total_calories")

    if the_meal.valid?
      the_meal.save
      redirect_to("/meals", { :notice => "Meal created successfully." })
    else
      redirect_to("/meals", { :alert => the_meal.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_meal = Meal.where({ :id => the_id }).at(0)

    the_meal.description = params.fetch("query_description")
    the_meal.fat = params.fetch("query_fat")
    the_meal.carbs = params.fetch("query_carbs")
    the_meal.protein = params.fetch("query_protein")
    the_meal.total_calories = params.fetch("query_total_calories")

    if the_meal.valid?
      the_meal.save
      redirect_to("/meals/#{the_meal.id}", { :notice => "Meal updated successfully." })
    else
      redirect_to("/meals/#{the_meal.id}", { :alert => the_meal.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_meal = Meal.where({ :id => the_id }).at(0)

    the_meal.destroy

    redirect_to("/meals", { :notice => "Meal deleted successfully." })
  end
end
