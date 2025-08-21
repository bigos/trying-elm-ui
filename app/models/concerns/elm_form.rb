class ElmForm
  include ActiveModel::Model

  attr_accessor :fexid, :compid, :brid


  # ContactMessage are never persisted in the DB
  def persisted?
    false
  end

  def elm_forms_path
    '/zzz'
  end
end
