class Api::FilesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def list
    params.permit!
    Rails.logger.info 'params-----------------------'
    Rails.logger.info params.inspect

    # debugger
    # 1==1

    # we do not have pwd yet, but try list the / files
    files = Dir.open('/').entries.sort
    render json: files.to_json
  end
end
