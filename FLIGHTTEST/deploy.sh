This file contains the bash commands used to deploy resources.
Both workspace and storage accounts are created using Bash CLI to simulate existing resources


- STEP: Create LAWS & Storage account. 

az monitor log-analytics workspace create \
    --workspace-name ToyLogs \
    -g learn-75968e44-6609-40b1-9f9b-b1fe45afef0d \
    --location eastus


az storage account create \
    -g learn-75968e44-6609-40b1-9f9b-b1fe45afef0d \
    -n logflighttestdata2812 \
    --location eastus

- STEP: Connect to Azure, set default and deploy resources. 

az login 
az account set --subscription 'Concierge Subscription'
az account list \
    --refresh \
    --query "[?contains(name, 'Concierge Subscription')].id" \
    --output table 

az account set --subscription 1f1aa1cf-6365-422a-8504-a1acdf9bc529
az configure --defaults group=learn-75968e44-6609-40b1-9f9b-b1fe45afef0d
az deployment group create \
    --template-file main.bicep \
    --parameters storageAccountName=logflighttestdata2812 

