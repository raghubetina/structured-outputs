class PagesController < ApplicationController
  def sandbox    
    # Prepare a hash that will become the headers of the request
    request_headers_hash = {
      "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
      "content-type" => "application/json"
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
          "content" => "You are an expert nutritionist. The user will describe a meal. Estimate the calories, carbs, fat, and protein."
        },
        {
          "role" => "user",
          "content" => "Burger, fries, milkshake"
        }
      ]
    }
    
    # Convert the Hash into a String containing JSON
    request_body_json = JSON.generate(request_body_hash)
    
    # Make the API call
    raw_response = HTTP.headers(request_headers_hash).post(
      "https://api.openai.com/v1/chat/completions",
      :body => request_body_json
    ).to_s
    
    # Parse the response JSON into a Ruby Hash
    @parsed_response = JSON.parse(raw_response)  

    render({ :template => "pages/sandbox" })
  end
end
