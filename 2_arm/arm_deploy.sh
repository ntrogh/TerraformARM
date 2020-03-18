# Create a resouce group as the target for the ARM deployment
az group create -n hashiarmrg -l westeurope

# Deploy the ARM template, providing parameter values via command-line
az group deployment create -g hashiarmrg --template-file arm_template.json --parameters storageAccountType=Standard_GRS

# Show the ARM deployment details for validation
az group deployment list -g hashiarmrg -o table
