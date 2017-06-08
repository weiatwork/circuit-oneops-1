powershell_script 'Start SQL Server' do
    code <<-EOH
	start-service mssqlserver
    EOH
end


