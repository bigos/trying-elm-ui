class Api::FilesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def list
    params.permit!

    dir = Dir.open(params["pwd"])

    files = dir.entries.sort
    files_filtered =
      if params["show_hidden"]
        files
      else
        files.reject { |f| f.start_with?(".") }
      end

    render json: { pwd: dir.to_path,
                   files: files_filtered }.to_json
  end
end
