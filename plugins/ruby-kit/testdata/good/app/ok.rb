# Good fixture: binds, allowlisted dispatch, documented allow.

def find_ok(id)
  User.where(id: id).first
end

def find_bind_ok(name)
  User.where("name = ?", name).first
end

ALLOWED = %w[draft publish archive].freeze

def dispatch_ok(action, record)
  raise ArgumentError, "unknown action" unless ALLOWED.include?(action)
  record.public_send(action)
end

# Documented intentional seam (boot probe); keep allow on the smell line.
def documented_legacy(code)
  eval(code) # ruby-rg-allow: fixture documents allow marker for intentional eval seam
end
