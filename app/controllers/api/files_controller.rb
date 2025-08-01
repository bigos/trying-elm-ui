class Api::FilesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def list
    params.permit!

    render json: Files.new(params['pwd'], params['show_hidden']).data
  end

  def get
    params.permit!

    logger.info "doing get for params #{params.inspect}"

    dir = Dir.open(params["pwd"])

    files = dir.entries.sort
    files_filtered =
      if params["show_hidden"]
        files
      else
        files.reject { |f| f.start_with?(".") }
      end

    render json: { pwd: dir.to_path,
                   show_hidden: params['show_hidden'],
                   files: files_filtered }.to_json
  end
end
