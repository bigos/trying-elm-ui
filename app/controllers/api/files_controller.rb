class Api::FilesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def list
    # we do not have pwd yet, but try list the / files
    render json: [ "/", [ ".", "this", "is", "a", "sample" ] ].to_json
  end
end
