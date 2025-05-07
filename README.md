
# 🏢 Infraestrutura de Rede Corporativa com Docker

Este projeto implementa uma infraestrutura de rede corporativa básica utilizando Docker, com serviços essenciais como DNS, DHCP, Firewall, LDAP, SAMBA, FTP e NGINX.

## 📦 Serviços Implementados

- **DNS** (Bind9): resolução de nomes internos e encaminhamento externo.
- **DHCP** (ISC DHCP): atribuição dinâmica de IPs com reservas.
- **Firewall** (iptables via container roteador): regras de segurança e roteamento entre sub-redes.
- **LDAP** (OpenLDAP): autenticação centralizada de usuários e grupos.
- **SAMBA**: compartilhamento de arquivos com autenticação via LDAP.
- **FTP** (vsftpd): transferência de arquivos segura.
- **NGINX**: servidor web com página de boas-vindas e Virtual Hosts.

## 🌐 Topologia de Rede

- Sub-rede 1: `192.168.1.0/24` – Servidores
- Sub-rede 2: `192.168.2.0/24` – Clientes
- Container `router`: responsável pelo roteamento e firewall entre as sub-redes.

## 📁 Estrutura de Diretórios

```
infra-rede-docker/
├── dns/
├── dhcp/
├── firewall/
├── ldap/
├── samba/
├── ftp/
├── nginx/
└── docker-compose.yml
```

## 🚀 Execução

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/RafaelTeixeira1/servico_redes.git
   ```

2. **Suba os containers com Docker Compose:**

   ```bash
   docker-compose up -d
   ```

3. **Verifique os logs de um serviço (exemplo: DNS):**

   ```bash
   docker logs dns
   ```

4. **Acesse os serviços:**

   - NGINX (web): http://localhost:8080  
   - FTP: via FileZilla, IP do container FTP, porta 21 (ou 20/990 se configurado FTPS)  
   - SAMBA: `\\<ip-do-container-samba>\compartilhamento`  
   - LDAP: via ferramenta como LDAP Admin ou `ldapsearch`  
   - DNS: testar com `dig` ou `nslookup` apontando para o IP do container DNS  
   - DHCP: testável em container cliente em outra sub-rede  

## 🧪 Testes Recomendados

- ✅ Verificar se os clientes recebem IP automaticamente via DHCP.
- ✅ Resolver nomes internos usando o servidor DNS.
- ✅ Testar bloqueio e liberação de portas via Firewall.
- ✅ Autenticar usuários nos serviços usando o LDAP.
- ✅ Compartilhar e acessar arquivos usando SAMBA.
- ✅ Transferir arquivos com segurança via FTP (FTPS ou SFTP).
- ✅ Acessar a página web de boas-vindas via NGINX.

## 🛠️ Observações Técnicas

> O container `router` é responsável por rotear pacotes entre as duas sub-redes (clientes e servidores) e aplicar as regras de firewall via iptables.  
> O serviço LDAP pode ser usado como backend de autenticação para o SAMBA e FTP.  
> Todos os containers compartilham a mesma rede Docker (bridge ou macvlan, conforme sua configuração), mas estão isolados em sub-redes distintas, conforme especificado no `docker-compose.yml`.

## 📑 Documentação Extra

- Arquivos de configuração estão organizados por pasta para cada serviço.
- Regras do firewall estão em `firewall/regras.sh` ou `router/firewall_rules.sh`.
- Exemplo de usuários e domínios em `ldap/base.ldif`.
- Os arquivos da web estão em `nginx/index.html` e `nginx/default.conf`.
- Zonas DNS estão em `dns/db.zona` e `dns/named.conf`.

## 📬 Contato

Para dúvidas ou sugestões, entre em contato com [rrafael_st@hotmail.com].
