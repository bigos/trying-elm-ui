class ElmFormController < ApplicationController
  def index
  end

  def new
    @elm_form = ElmForm.new
    @elm_form.fexid = 1
    @elm_form.compid = 2
    @elm_form.brid = 3
  end
end
