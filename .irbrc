Dir.glob("*.rb") do |rb|
  require_relative rb
end
