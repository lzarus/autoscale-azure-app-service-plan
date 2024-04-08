# Scale Up and Down App Service Plan

This script is designed to scale up and down Azure App Service Plans in multiple subscriptions and resource groups.

## Configuration

The script takes the following parameters:

- `ARM_TENANT_ID`: The Azure AD tenant ID for authentication.
- `ARM_CLIENT_ID`: The client ID of the service principal for authentication.
- `ARM_CLIENT_SECRET`: The client secret of the service principal for authentication.
- `Subscriptions`: An array of subscription objects containing subscription ID, resource groups, and App Service plans to be scaled up or down.

## Usage

You can use the script by providing the necessary parameters and executing it. It will then iterate through the specified subscriptions and resource groups to scale up or down the specified App Service Plans.

## Functions

### `ScaleUpAppServicePlan`

This function takes the resource group name, App Service Plan name, desired size (up), and subscription ID as parameters. It uses Azure CLI commands to check and scale up the App Service Plan if necessary.

### `ScaleDownAppServicePlan`

This function takes the resource group name, App Service Plan name, desired size (down), and subscription ID as parameters. It uses Azure CLI commands to check and scale down the App Service Plan if necessary.

### Main Script

The script connects to Azure using the specified service principal, iterates through the subscriptions and resource groups, and scales up or down the specified App Service Plans as needed.

