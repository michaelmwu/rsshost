class FileController < ApplicationController
  http_basic_authenticate_with name: ENV['BASIC_USERNAME'], password: ENV['BASIC_PASSWORD'], except: :show

  def to_key(name)
    "file:#{name}"
  end

  def update
    if params[:name].blank?
      render json: "Needs a name", status: :bad_request
    end

    if params[:body].blank?
      render json: "Needs a body", status: :bad_request
    end

    if params[:type].blank?
      params[:type] = "text/html"
    end

    value = {type: params[:type].to_s, body: params[:body].to_s}

    $redis.set(to_key(params[:name]), value.to_json)

    render json: "Success", status: :ok
  end

  def show
    content = $redis.get(to_key(params[:name]))

    if not content
      render json: "Not found", status: :conflict and return
    end

    content = JSON.parse(content)

    render content_type: content["type"], body: content["body"]
  end
end
