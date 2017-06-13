powershell_script 'Restart SQL Server' do
    code <<-EOH
	restart-service -force mssqlserver
    EOH
end


