include_recipe "inductor::cloud"

execute "inductor stop #{node[:inductor_cloud]}" do
  cwd node[:inductor][:inductor_home]
end

execute "inductor disable #{node[:inductor_cloud]}" do
  cwd node[:inductor][:inductor_home]
end
