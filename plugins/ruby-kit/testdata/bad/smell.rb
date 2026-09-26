# Intentional smells for ruby-rg-gate discrimination (not product code).

def run_bad(code)
  eval(code)
end

def dispatch_bad(name, *args)
  public_send("#{name}", *args)
end

def params_send_bad(params)
  send(params[:method])
end

def query_bad(id)
  User.where("id = #{id}")
end
