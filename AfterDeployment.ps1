##############################################################################
# Susbcription where we need to set permissions for the workflow's managed identity
$sourceSubscriptionID = "Subscription where WF is installed"
$targetSubscriptionID = "Subscription which contains the RG to be deleted"
# Resource group where the workflow was deployed
$resourceGroup = "garbagecollector"
# Storage account name which was provided during deployement
$storageAccount = "garbagecollector"
# Storage table which we want to create
$storageTable = "garbagecollector"
# Each name of the workflow
$getWorkflow = "get-rg-logic"
$deleteWorkflow = "delete-rg-logic"
##############################################################################
# Create storage table
# Initialize the source environment by setting the default subscription
$subscriptionObject = Get-AzSubscription -SubscriptionId $sourceSubscriptionID
Set-AzContext -SubscriptionObject $subscriptionObject

# Get the storage account and create a storage table
$context = (Get-AzStorageAccount -StorageAccountName $storageAccount -ResourceGroupName $resourceGroup).Context
New-AzStorageTable -Name $storageTable -Context $context

##############################################################################
# Assign permission for each Logic App workflow (system managed identity)
# Get each of the managed identity of each workflow
$msiGetWorkflow = (Get-AzADServicePrincipal -DisplayName $getWorkflow ).Id
$msiDeleteWorkflow = (Get-AzADServicePrincipal -DisplayName $deleteWorkflow).Id

# Initialize the target environment by setting the default subscription
$subscriptionObject = Get-AzSubscription -SubscriptionId $targetSubscriptionID
Set-AzContext -SubscriptionObject $subscriptionObject

# Set the permissions for "get workflow"
New-AzRoleAssignment -ObjectId $msiGetWorkflow -RoleDefinitionName "Contributor" -Scope "/subscriptions/$sourceSubscriptionID/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccount"
New-AzRoleAssignment -ObjectId $msiGetWorkflow -RoleDefinitionName "Reader" -Scope /subscriptions/$targetSubscriptionID

# Set permissions for "delete workflow"
New-AzRoleAssignment -ObjectId $msiDeleteWorkflow -RoleDefinitionName "Contributor" -Scope "/subscriptions/$sourceSubscriptionID/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccount"
New-AzRoleAssignment -ObjectId $msiDeleteWorkflow -RoleDefinitionName "Contributor" -Scope /subscriptions/$targetSubscriptionID