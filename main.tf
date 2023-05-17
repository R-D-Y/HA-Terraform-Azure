terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = ""
}

# Création du groupe de ressources
resource "azurerm_resource_group" "example" {
  name     = "myRG" 
  location = "FranceCentral"
}

# Création du réseau virtuel
resource "azurerm_virtual_network" "example" {
  name                = "Myvnet" 
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Création du sous-réseau
resource "azurerm_subnet" "example" {
  name                 = "Mysubnet" 
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Création de l'ensemble de disponibilité
resource "azurerm_availability_set" "example" {
  name                = "Myavailability-set" 
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Création des machines virtuelles
resource "azurerm_virtual_machine" "example" {
  count                 = 2
  name                  = "Myvm-${count.index}" 
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  availability_set_id   = azurerm_availability_set.example.id
  network_interface_ids = [azurerm_network_interface.example[count.index].id]
  vm_size               = "Standard_DS2_v2"

  storage_os_disk {
    name              = "Myosdisk-${count.index}" 
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "My-vm-${count.index}" 
    admin_username = ""
    admin_password = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


# Extension de script personnalisé pour la première machine virtuelle
resource "azurerm_virtual_machine_extension" "example1" {
  name                 = "customscript1"
  virtual_machine_id   = azurerm_virtual_machine.example[0].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash -c 'sudo apt -y update && sudo apt -y upgrade && sudo apt -y install nginx && sudo rm /var/www/html/*html && sudo wget https://raw.githubusercontent.com/R-D-Y/HTML-PROJET/main/HTML-PAGE-NODE-2.html -O /var/www/html/index.html && sudo systemctl restart nginx.service'"
    }
SETTINGS
}

# Extension de script personnalisé pour la deuxième machine virtuelle
resource "azurerm_virtual_machine_extension" "example2" {
  name                 = "customscript2"
  virtual_machine_id   = azurerm_virtual_machine.example[1].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash -c 'sudo apt -y update && sudo apt -y upgrade && sudo apt -y install nginx && sudo rm /var/www/html/*html && sudo wget https://raw.githubusercontent.com/R-D-Y/HTML-PROJET/main/HTML-PAGE-NODE-1.html -O /var/www/html/index.html && sudo systemctl restart nginx.service'"
    }
SETTINGS
}


resource "azurerm_network_interface" "example" {
  count               = 2
  name                = "My-nic-${count.index}" 
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "My-ipconfig" 
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Création du Load Balancer
resource "azurerm_lb" "example" {
  name                = "My-lb" 
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = "My-lb-frontend" 
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

# Création du Pool d'adresses IP du Load Balancer
resource "azurerm_lb_backend_address_pool" "example" {
  name            = "My-lb-backend-pool" 
  loadbalancer_id = azurerm_lb.example.id
}

# Association des adresses IP des machines virtuelles au Pool d'adresses IP du Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                 = 2
  network_interface_id  = azurerm_network_interface.example[count.index].id
  ip_configuration_name = azurerm_network_interface.example[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
}

# Création de l'adresse IP publique
resource "azurerm_public_ip" "example" {
  name                = "My-public-ip" 
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"  # Allocation statique de l'adresse IP publique
}


# Configuration des règles du Load Balancer
resource "azurerm_lb_rule" "example" {
  name                          = "My-lb-rule" 
  loadbalancer_id               = azurerm_lb.example.id
  frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.example.id]
  protocol                      = "Tcp"
  frontend_port                 = 80
  backend_port                  = 80
}
