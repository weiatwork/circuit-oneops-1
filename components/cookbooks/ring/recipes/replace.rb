deps = node.workorder.payLoad.DependsOn

db_type = nil
is_redis = false
deps.each do |dep|
  class_name = dep['ciClassName'].split('.').last
  db_type = dep['ciClassName'].split('.').last.downcase
  if class_name == "Redisio"
    is_redis = true
    include_recipe "ring::replace_#{db_type}"
  end
end

if !is_redis
  include_recipe "ring::add"
end
