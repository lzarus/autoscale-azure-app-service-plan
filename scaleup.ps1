
Param(
    $ARM_TENANT_ID = "x",    
    $ARM_CLIENT_ID = "x",    
    $ARM_CLIENT_SECRET = 'x',
    $Subscriptions = @(
        @{
            #Subscription 1
            "SubscriptionId" = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
            "ResourceGroups" = @(
                @{
                    "ResourceGroupName" = "rg-01"
                    "AppServicePlanNames"     = @("asp01")
                    "SizeUp" = "B2"
                }
            )
        }
        @{
            #Subscription 2
            "SubscriptionId" = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
            "ResourceGroups" = @(
                @{
                    "ResourceGroupName" = "rg-02"
                    "AppServicePlanNames"     = @("asp02")
                    "SizeUp" = "S2"
                },
                @{
                    "ResourceGroupName" = "rg-03"
                    "AppServicePlanNames"     = @("asp031","asp032")
                    "SizeUp" = "S2"
                }
            )
        }
    )
) #EndParam
function ScaleUpAppServicePlan($resourceGroupName, $AppServicePlanName,$sizeUps, $subscriptionId) {
    # $server = Get-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $AppServicePlanName -SubscriptionId $subscriptionId 
    # $server = az appservice plan show --resource-group $resourceGroupName --name $AppServicePlanName --subscription $subscriptionId --output yaml
    # az appservice plan show --resource-group $resourceGroupName --name $AppServicePlanName --subscription $subscriptionId --output jsonc --query "sku.size"
     $server = az appservice plan show --resource-group $resourceGroupName --name $AppServicePlanName --subscription $subscriptionId 
     if (!$server) {
        Write-Output "`t`t`t App Service Plan $AppServicePlanName not found in resource group  $resourceGroupName"
        return
    }
    $serverSize = az appservice plan show --resource-group $resourceGroupName --name $AppServicePlanName --subscription $subscriptionId --output jsonc --query "sku.size" | ConvertFrom-Json
    Write-Host "$serverSize : $sizeUps"
    if ($serverSize -eq $sizeUps) {
        Write-Output "`t`t`tThe App Service Plan $AppServicePlanName is already with this size $sizeUps "
        return
    }
    else {
        $scaleUpCommand = az appservice plan update --resource-group $resourceGroupName --name $AppServicePlanName --subscription $subscriptionId --sku $sizeUps
        if ($?) {
            Write-Output "`t`t`tScaleUp App Service Plan $AppServicePlanName in resource group $resourceGroupName to $sizeUps"
        } else {
            Write-Output "An error occurred while scaling up App Service Plan $AppServicePlanName in resource group $resourceGroupName"
        }
    }
}

# Checkout in Subscription
foreach ($subscription in $Subscriptions) {
    $subscriptionId = $subscription.SubscriptionId
    $resourceGroups = $subscription.ResourceGroups

    # Authentification using SP
    $SecureStringPwd = $ARM_CLIENT_SECRET | ConvertTo-SecureString -AsPlainText -Force
    $pscredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ARM_CLIENT_ID, $SecureStringPwd
    Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $ARM_TENANT_ID
    Set-AzContext -SubscriptionId $subscriptionId

    Write-Output "Processing resources in subscription $subscriptionId"

    foreach ($resourceGroup in $resourceGroups) {
        $resourceGroupName = $resourceGroup.ResourceGroupName
        $AppServicePlanNames = $resourceGroup.AppServicePlanNames
        $sizeUps             = $resourceGroup.SizeUp

        Write-Output "`tProcessing resources in resource group $resourceGroupName"

        # ScaleUp each AppServicePlanNames
        foreach ($AppServicePlanName in $AppServicePlanNames) {
            Write-Output "`t`tProcessing App Service Plan  $AppServicePlanName"
            ScaleUpAppServicePlan $resourceGroupName $AppServicePlanName $sizeUps $subscriptionId
        }
    }
}