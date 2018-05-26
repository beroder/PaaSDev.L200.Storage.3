$resourcegroupname = "PaaSDev.L200.Storage.3"

Write-Host "Logging in..."
Login-AzureRmAccount

Write-Host "Creating resource group..."
New-AzureRmResourceGroup -Name $resourcegroupname -Location "East US" -Force
Write-Host "Deploying storage account..."
New-AzureRmResourceGroupDeployment -Name $resourcegroupname -ResourceGroupName $resourcegroupname -TemplateFile .\storage.json