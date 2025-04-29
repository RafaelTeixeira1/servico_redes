----------------

```bash
                                            ▄▄▄▄▄     ▄▄    ▄▄     ▄▄▄▄   ▄▄▄▄▄▄   
                                            ██▀▀▀██   ██    ██   ██▀▀▀▀█  ██▀▀▀▀█▄ 
                                            ██    ██  ██    ██  ██▀       ██    ██ 
                                            ██    ██  ████████  ██        ██████▀  
                                            ██    ██  ██    ██  ██▄       ██       
                                            ██▄▄▄██   ██    ██   ██▄▄▄▄█  ██       
                                            ▀▀▀▀▀     ▀▀    ▀▀     ▀▀▀▀   ▀▀ 

```
--------------

# Configuração

 1. Para começar, instale o serviço isc-dhcp-server usando o comando abaixo:
    
    ```bash
      apt install -y isc-dhcp-server
    ```

2. Em seguida, é necessário fazer um backup do arquivo original de configuração e substituí-lo pelo novo arquivo localizado em /vagrant_config/DHCP/dhcpd.conf. Utilize os comandos a seguir:
    
    ```bash
      mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp
      cp /vagrant_config/DHCP/dhcpd.conf /etc/dhcp/dhcpd.conf
    ```

3. Após isso, reinicie o serviço DHCP no servidor e execute os comandos de liberação e renovação do IP na máquina cliente:

    ```bash
       systemctl restart isc-dhcp-server // No servidor
       sudo dhclient -r <interface> // Na máquina do cliente
       sudo dhclient <interface> // Na máquina do cliente
    ```
-----------
# O arquivo dhcpd.conf

O arquivo dhcpd.conf define os parâmetros básicos para o funcionamento do serviço DHCP. Um exemplo de configuração funcional está abaixo:

```shell
  # dhcpd.conf
  #
  # Sample configuration file for ISC dhcpd
  #
  # Attention: If /etc/ltsp/dhcpd.conf exists, that will be used as
  # configuration file instead of this file.
  #
  
  # option definitions common to all supported networks...
  option domain-name "example.org";
  option domain-name-servers ns1.example.org, ns2.example.org;
  
  default-lease-time 600;
  max-lease-time 7200;
  
  ddns-update-style none;
  
  subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.99 192.168.1.200;
  option subnet-mask 255.255.255.0;
  option domain-name "iftm.edu.br";
  option domain-name-servers 8.8.8.8, 8.8.4.4;
  option routers 192.168.1.1;
  default-lease-time 600;
  max-lease-time 7200;
  }
```

### Explicando algumas diretivas

- `subnet 192.168.1.0 netmask 255.255.255.0`:  Inicia a configuração da subrede 192.168.1.0 com máscara 255.255.255.0.
- `range 192.168.1.99 192.168.1.200;`: Especifica o intervalo de endereços IP que o servidor poderá alocar dinamicamente aos clientes.
- `option domain-name-servers 8.8.8.8, 8.8.4.4;`: Define os servidores DNS que serão informados aos clientes (neste caso, os servidores públicos do Google).
- `option routers 192.168.1.1;`: Define o gateway padrão que os clientes devem utilizar.
- `default-lease-time 600; && max-lease-time 7200;`: Estabelecem o tempo padrão e o tempo máximo para a concessão dos endereços IP.
