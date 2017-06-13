powershell_script 'Stop SQL Server' do
    code <<-EOH
	stop-service -force mssqlserver
    EOH
end


