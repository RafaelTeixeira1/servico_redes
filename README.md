
# 🏢 Infraestrutura de Rede Corporativa com Docker

Este projeto implementa uma infraestrutura de rede corporativa básica utilizando Docker. A estrutura inclui serviços essenciais como DNS, DHCP, Firewall, LDAP, SAMBA, FTP e NGINX. O objetivo é simular um ambiente corporativo com autenticação centralizada, compartilhamento de arquivos, serviços de rede e servidor web.

## 🛠️ Objetivos

Implementar uma infraestrutura de rede corporativa básica, integrando serviços essenciais para gestão e segurança de redes utilizando containers Docker.

## 📦 Serviços Implementados

- **DNS-** (Bind9): resolução de nomes internos e encaminhamento externo.
- **DHCP-** (ISC DHCP): atribuição dinâmica de IPs com reservas.
- **Firewall** (iptables via container roteador): regras de segurança e roteamento entre sub-redes.
- **LDAP** (OpenLDAP): autenticação centralizada de usuários e grupos.
- **SAMBA**: compartilhamento de arquivos com autenticação via LDAP.
- **FTP** (vsftpd): transferência de arquivos segura.
- **NGINX**: servidor web com página de boas-vindas e Virtual Hosts.


## 🚀 Requisitos

- Docker
- Docker Compose

## 📁 Estrutura de Diretórios

```
/
├── docker-compose.yml
├── dns-server/
│   └── Dockerfile
│   └── setup-bind.sh
├── dhcp-server/
│   └── Dockerfile
│   └── dhcpd.conf
├── firewall/
│   └── Dockerfile
│   └── firewall.sh
├── ftp-server/
│   └── Dockerfile
│   └── vsftpd.conf
├── ldap-server/
│   └── Dockerfile
│   └── bootstrap.ldif
├── samba-server/
│   └── Dockerfile
│   └── smb.conf
├── web-server/
│   └── Dockerfile
│   └── default.conf
│   └── index.html
└── router/
    └── Dockerfile
    └── start.sh
```

## 🚀 Como Executaro Projeto

1. **Clone o repositório:**

   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd <NOME_DO_REPOSITORIO>
   ```

2. **Execute o comando para iniciar todos os containers::**

   ```bash
   docker-compose up --build -d
   ```

3. **Verifique os containers em execução:**

   ```bash
   docker ps
   ```

4. **Para acessar um container específico:**

   ```bash
   docker exec -it <container_name> /bin/bash
   ```

5. **Para encerrar todos os containers:**

   ```bash
   docker-compose down
   ```
   
## 🧪 Testes Recomendados

- ✅ Verificar se os clientes recebem IP automaticamente via DHCP.
- ✅ Resolver nomes internos usando o servidor DNS.
- ✅ Testar bloqueio e liberação de portas via Firewall.
- ✅ Autenticar usuários nos serviços usando o LDAP.
- ✅ Compartilhar e acessar arquivos usando SAMBA.
- ✅ Transferir arquivos com segurança via FTP (FTPS ou SFTP).
- ✅ Acessar a página web de boas-vindas via NGINX.

## 🛠️ Observações Técnicas

- **FTP Server-**: Configurado em ftp-server/vsftpd.conf
- **DHCP Server-**: Configurado em dhcp-server/dhcpd.conf
- **DNS Server-**: Configurado em dns-server/setup-bind.sh
- **Firewall-**: Regras configuradas em firewall/firewall.sh

## 📦 Comandos Úteis

- Recompilar as imagens sem cache
   ```bash
   docker-compose build --no-cache
   ```
- Ver logs em tempo real
   ```bash
   docker-compose logs -f
   ```
- Restartar um container específico:
   ```bash
   docker-compose restart <container_name>
   ```

## 📬 Contato

Para dúvidas ou sugestões, entre em contato com [rrafael_st@hotmail.com ou jhannyferbiangulo@gmail.com].
