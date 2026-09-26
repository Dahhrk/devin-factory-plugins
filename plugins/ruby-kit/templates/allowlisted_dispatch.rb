# Named boundary: prefer allowlisted dispatch over interpolated send/public_send.
# Copy into product sources; keep ruby-rg-allow only on intentional seams.

module AllowlistedDispatch
  ALLOWED = %w[draft publish archive].freeze

  module_function

  def call(record, action)
    raise ArgumentError, "unknown action: #{action}" unless ALLOWED.include?(action.to_s)

    record.public_send(action)
  end
end
