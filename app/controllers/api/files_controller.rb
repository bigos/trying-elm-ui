class Api::FilesController < ApplicationController


  def list
    # we do not have pwd yet, but try list the / files
    render :json ["/", [ ".", "zzz" ]]
  end

end
