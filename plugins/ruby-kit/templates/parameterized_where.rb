# Named boundary: prefer binds / hash conditions over SQL string interpolate.
# Copy into product sources; keep ruby-rg-allow only on intentional seams.

module ParameterizedWhere
  module_function

  def find_by_id(scope, id)
    scope.where(id: id).first
  end

  def find_by_name(scope, name)
    scope.where("name = ?", name).first
  end
end
