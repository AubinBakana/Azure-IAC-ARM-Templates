az login
az account set --subscription "Concierge Subscription"
az account list --refresh --query "[?contains(name, 'Concierge Subscription')].id" --output table
az configure --defaults group=learn-2d4a32f0-e87d-428a-a849-fe0be5e9b45f
az ts create --name ToyCosmosDBAccount --location westus --display-name "Cosmos DB account" --description "This template spec creates a Cosmos DB account that meets our company's requirements." --version 1.0 --template-file main.bicep
id=$(az ts show --name ToyCosmosDBAccount --resource-group learn-2d4a32f0-e87d-428a-a849-fe0be5e9b45f --version "1.0" --query "id")
az deployment group create --template-spec $id


# Version 2
az ts create --name ToyCosmosDBAccount --version 2.0 --version-description "Adds Cosmos DB role-based access control." --template-file main.bicep
id=$(az ts show --name ToyCosmosDBAccount --resource-group learn-2d4a32f0-e87d-428a-a849-fe0be5e9b45f --version "1.0" --query "id")


userObjectId=$(az ad signed-in-user show --query id --output tsv)

id=$(az ts show --name ToyCosmosDBAccount --resource-group learn-2d4a32f0-e87d-428a-a849-fe0be5e9b45f --version 2.0 --query "id")
az deployment group create --template-spec $id --parameters roleAssignmentPrincipalId="d68d19b3-d7ef-4ae9-9ee4-90695a4e417d"