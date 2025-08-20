For detailed architecture information, see [Solution Architecture](docs/solution-architecture.md).

## 🚀 Getting Started

### Prerequisites
- Azure CLI
- Azure subscription
- Visual Studio Code with [Bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)
- PowerShell 7+ or Azure PowerShell

### Quick Start
1. Clone the repository
   ```powershell
   git clone https://github.com/MariusM26/IaCBicep.git
   cd Marad-Cloud-IaC
   ```

2. Setup az CLI

   ```powershell
   # Sign in to Azure using your credentials
   az login

   # Display details of the currently active Azure subscription
   az account show

   # List all available Azure subscriptions in a table format
   az account list --output table

   # Set a specific subscription as the active one for subsequent commands
   az account set --subscription <subscription-id>

   # Show the current default configuration settings for az CLI
   az configure --list-defaults

   # List all resource groups in the active subscription
   az group list --output table

   # Set a default resource group for subsequent commands
   az configure --defaults group=ResourceGroupName
   ```
3. Deploy the infrastructure
   ```powershell
   cd deploy
   
   # For targetScope resourceGroup
   az deployment group create --name main --resource-group ResourceGroupName --template-file main.bicep

   # For targetScope subscription
   az deployment sub create --location westeurope --template-file main.bicep --parameters env=dev
   ```

## 📁 Repository Structure
```
├── deploy/                 # Deployment files
│   ├── azure-pipelines.yml # CI/CD pipeline definition
│   ├── main.bicep         # Main deployment template
│   ├── parameters.bicep   # Parameters file
│   └── modules/           # Reusable Bicep modules
│       ├── resource-groups/
│       └── resources/
└── docs/                  # Documentation
```

## 🛠️ Development

### Local Development
1. Use VS Code with Bicep extension for IntelliSense and syntax highlighting
2. Test changes locally using `az deployment sub what-if`
3. Use the built-in Bicep visualizer (Ctrl+K V) to view dependencies

### CI/CD Pipeline
The project includes an Azure DevOps pipeline that:
1. Validates Bicep templates
2. Creates ARM templates
3. Deploys to dev/test/prod environments sequentially

## 📝 Parameters

Main deployment parameters:
- `location` - Azure region (default: WestEurope)
- `env` - Environment name (dev/test/prod)

## 🔒 Security

The infrastructure implements security best practices:
- Network isolation using Virtual Networks
- Private endpoints for PaaS services
- Managed Identities for authentication
- Key Vault for secrets management

## 📊 Monitoring

Monitoring is implemented using:
- Azure Monitor
- Log Analytics Workspace
- Application Insights
- Custom dashboards

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.