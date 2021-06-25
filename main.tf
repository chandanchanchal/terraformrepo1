provider "azurerm" {
  features {
    
  }
}

resource "azurerm_resource_group" "tfrg" {
  name = "tffirstconfig"
  location = "eastus"
}

resource "azurerm_virtual_network" "tfvnet" {
  name = "vNET"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
}

resource "azurerm_subnet" "subnet" {
  name ="internal"
  resource_group_name = azurerm_resource_group.tfrg.name
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  address_prefix = "10.0.0.0/24"
}
resource "azurerm_network_interface" "example"{
  name = "example-nic"
  location = azurerm_resource_group.tfrg.location
  resource_group_name =  azurerm_resource_group.tfrg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}
resource "azurerm_availability_set" "DemoAset" {
  name                = "example-aset"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_windows_virtual_machine" "example"{
 name = "example-machine"
 resource_group_name = "azurerm_resource_group.tffirstconfig.name"
 location = azurerm_resource_group.tfrg.location
 size = "Standerd_F2"
 admin_username = "adminuser"
 admin_password = "P@$$wOrd1234!"
 availability_set_id = azurerm_availability_set.DemoAset.id
 network_interface_ids = [azurerm_network_interface.example.id,]
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

 source_image_reference{
   publisher = "MicrosoftWindowsServer"
   offer = "WindowsServer"
   sku = "2016-Datacenter"
   version = "latest"
 }


}
