class Api::FilesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def list
    params.permit!
    Rails.logger.info "params-----------------------"
    Rails.logger.info params.inspect

    # debugger
    # 1==1

    # we do not have pwd yet, but try list the / files
    files = Dir.open(params["pwd"]).entries.sort
    files_filtered =
      if params["show_hidden"]
        files
      else
        files.reject{ |f| f.start_with?('.') }
      end
    render json: files_filtered.to_json
  end
end
