# Docker Compose para Serviços de Rede e Diretórios

Este repositório disponibiliza uma configuração com Docker Compose para implantar serviços essenciais de rede e diretórios, como DNS, OpenLDAP, Nginx, FTP e Samba. Todos os serviços rodam em containers Docker integrados por redes virtuais dedicadas.

## Topologia de Rede

A infraestrutura está organizada em uma topologia onde os serviços se conectam por redes isoladas, com um firewall central atuando como gateway entre os clientes externos e os servidores internos.

### Visão Geral

- **Firewall**: Atua como ponto de entrada e saída de tráfego, fornecendo segurança e controle sobre a comunicação com os serviços internos.
- **Serviços de Rede**: Incluem DNS (BIND9), Nginx, OpenLDAP, FTP e Samba, interligados por redes internas para facilitar a comunicação segura.
- **Redes Virtuais**: Dois tipos de redes virtuais são utilizados:
  - **server_network**: Rede interna usada exclusivamente para a comunicação entre os serviços.
  - **client_network**: Rede que permite a comunicação entre os serviços e os clientes externos (web, FTP, etc).

### Diagrama da Topologia

````bash
                    +-----------------+
                    |     CLIENTES    |
                    +--------+--------+
                             |
                             |
                      +------v-------+
                      |  FIREWALL    |
                      |  (Gateway)   |
                      +------^-------+
                             |
           +-----------------+-----------------+
           |                 |                 |
  +--------v--------+ +------v-------+ +-------v-------+
  |     NGINX       | |     OPENLDAP  | |     SAMBA     |
  +-----------------+ +--------------+ +---------------+
           |                      |
  +--------v--------+         +------v-------+
  |      DNS        |         |     FTP      |
  +-----------------+         +--------------+

````


### Descrição da Topologia

1. **Clientes**: Acessam os serviços através do firewall, como páginas web pelo Nginx, arquivos via FTP ou compartilhamentos via Samba.

2. **Firewall (Gateway)**: Gerencia e filtra o tráfego entre o mundo externo e os serviços internos, conforme as regras de segurança definidas.

3. **Serviços Internos**:
   - **Nginx**: Servidor web para conteúdo estático e redirecionamento de tráfego.
   - **DNS (BIND9)**: Resolve nomes de domínio dentro da rede.
   - **OpenLDAP**: Gerencia autenticação e diretórios de usuários.
   - **FTP (ProFTPD)**: Transferência de arquivos, com suporte a usuário anônimo.
   - **Samba**:  Compartilhamento de arquivos via protocolo SMB/CIFS.

### Fluxo de Dados

1. **Clientes** realiza uma requisição, como acessar um site via Nginx.**.
2. O **Firewall** direciona o tráfego para o **Nginx** ou outros serviços, conforme a configuração da rede.
3. Os serviços internos como **DNS**, **OpenLDAP**, **FTP**, e **Samba** se comunicam através das redes internas (`server_network` e `client_network`), mas o tráfego externo é filtrado pelo **Firewall**.

### Configuração do Firewall

O firewall pode ser implementado como um container Docker ou máquina virtual, atuando como gateway e aplicando regras de filtragem de pacotes conforme as políticas de segurança.

### Considerações Finais

- O uso de um **firewall** como intermediário de rede reforça a segurança dos serviços internos.
- O isolamento das redes virtuais evita acessos indesejados entre os containers.
- A estrutura é ideal para testes, ambientes educacionais ou de desenvolvimento que demandam controle de rede e segmentação entre serviços.


## Como Usar

1. **Requisitos**: Antes de começar, assegure-se de que o Docker e o Docker Compose estejam corretamente instalados.

2. **Iniciar os serviços**:
   ```bash
   docker-compose up -d




# Serviços

# 1. **DNS (BIND9)**
- **Imagem**: `ubuntu/bind9`
- **Portas**: Não expostas diretamente
- **Volumes**:
  - `./DNS/named.conf.local:/etc/bind/named.conf.local`
  - `./DNS/named.conf.options:/etc/bind/named.conf.options`
- **Rede**: `server_network`
- **Função**: Servidor DNS utilizando BIND9, com arquivos de configuração locais.

##### O arquivo named.conf.local

Este arquivo é essencial para definir as zonas de domínio no servidor DNS. Cada zona aponta para um arquivo de configuração distinto.

Exemplo de configuração:

```bash
zone "exemplo.com" {
    type master;
    file "/etc/bind/db.exemplo.com";
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.1";
};
```

### O arquivo db.exemplo.com

Aqui são definidas as associações de nomes com IPs, incluindo o servidor autoritativo (SOA) e os registros de nome (A) e servidores de nome (NS).

Exemplo:

```bash
$TTL    604800
@       IN      SOA     ns.exemplo.com. root.exemplo.com. (
                        2         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL
;
@       IN      NS      ns.exemplo.com.
@       IN      A       192.168.1.100
ns      IN      A       192.168.1.100
www     IN      A       192.168.1.101
ftp     IN      A       192.168.1.102
```

### O arquivo db.192.168.1

Este arquivo é utilizado para a resolução reversa de IPs para nomes de domínio.

Exemplo:

```bash
$TTL    604800
@       IN      SOA     ns.exemplo.com. root.exemplo.com. (
                        1         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL
;
@       IN      NS      ns.exemplo.com.
100     IN      PTR     ns.exemplo.com.
101     IN      PTR     www.exemplo.com.
102     IN      PTR     ftp.exemplo.com.
```

---------------------------------

# 2. **Nginx**
- **Imagem**: `nginx:alpine`
- **Portas**: `8080:80`
- **Volumes**:
  - `./nginx/nginx.conf:/etc/nginx/conf.d/default.conf`
  - `./nginx/html/:/usr/share/nginx/html/`
- **Redes**: `server_network`, `client_network`
- **Função**: Servidor web Nginx, configurado para servir arquivos estáticos e redirecionar tráfego HTTP.

### O arquivo `nginx.conf`

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
}

http {

	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	gzip on;


	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;

	server {
    	listen       80 default_server;
    	listen       [::]:80 default_server;
    	server_name  _;
    	root         /usr/share/nginx/html;
	}
	
	server {
		server_name  example.com;
		root         /var/www/example.com/;
		access_log   /var/log/nginx/access.log;
		error_log    /var/log/nginx/error.log;
	}

}

```

### Explicando algumas diretivas

No bloco de configuração do nginx.conf, o bloco principal onde realizamos as configurações é o bloco http, onde configuramos o servidor com as diretivas de server. Veja abaixo algumas das diretivas mais comuns:

- `listen       80 default_server;`: Define o servidor para escutar na porta 80 no protocolo IPv4. Esta diretiva especifica em qual porta o servidor vai aguardar por conexões. No caso, a porta 80 é a porta padrão para o protocolo HTTP.
- `listen       [::]:80 default_server;`: Define o servidor para escutar na porta 80, mas agora utilizando o protocolo IPv6. A sintaxe [::] é uma representação abreviada do endereço IPv6 para todos os endereços possíveis.
- `root         /var/www/example.com/;`:  Define o diretório raiz onde o servidor nginx irá buscar os arquivos, como arquivos HTML, imagens e outros recursos, quando um usuário acessar o site.
- `access_log && error_log`: Estas diretivas configuram os diretórios onde o servidor vai registrar os arquivos de log de acesso e de erro. O log de acesso contém informações sobre as requisições feitas ao servidor, enquanto o log de erro contém detalhes sobre falhas ou problemas durante o processamento de uma requisição.
------------------------

## 3. **OpenLDAP**

- **Imagem**: `bitnami/openldap:latest`
- **Container Name**: `openldap`
- **Portas Expostas**:
  - `389:389` → Conexões LDAP sem TLS
  - `636:636` → Conexões LDAP com TLS (LDAPS)

- **Volumes Montados**:
  | Volume Local                           | Volume no Container                           | Descrição                                   |
  |----------------------------------------|----------------------------------------------|---------------------------------------------|
  | `./data/certificates`                  | `/container/service/slapd/assets/certs`      | Certificados TLS (server.crt, server.key, etc.) |
  | `./data/slapd/database`                | `/var/lib/ldap`                              | Banco de dados LDAP persistente             |
  | `./data/slapd/config`                  | `/etc/ldap/slapd.d`                          | Configuração dinâmica do OpenLDAP          |

- **Variáveis de Ambiente**:
  | Variável de Ambiente                 | Descrição                                                                       |
  |--------------------------------------|---------------------------------------------------------------------------------|
  | `LDAP_ORGANISATION`                  | Nome da organização no LDAP (ex: `ramhlocal`)                                  |
  | `LDAP_DOMAIN`                        | Domínio LDAP (ex: `ramhlocal.com` → `dc=ramhlocal,dc=com`)                      |
  | `LDAP_ADMIN_USERNAME`                | Nome de usuário do administrador LDAP (ex: `admin`)                            |
  | `LDAP_ADMIN_PASSWORD`                | Senha do administrador LDAP (ex: `admin_pass`)                                 |
  | `LDAP_BASE_DN`                       | Base DN para busca no LDAP (ex: `dc=ramhlocal,dc=com`)                         |
  | `LDAP_TLS_CRT_FILENAME`              | Nome do arquivo de certificado TLS (ex: `server.crt`)                          |
  | `LDAP_TLS_KEY_FILENAME`              | Nome do arquivo de chave privada TLS (ex: `server.key`)                        |
  | `LDAP_READONLY_USER`                 | Se `true`, cria um usuário com permissão somente leitura (default: `false`)     |
  | `LDAP_READONLY_USER_USERNAME`        | Nome do usuário somente leitura (default: `user-ro`)                           |
  | `LDAP_READONLY_USER_PASSWORD`        | Senha do usuário somente leitura (default: `ro_pass`)                          |

- **Rede**: `server_network` (Rede interna para isolamento)

- **Função**: Servidor LDAP utilizado para autenticação centralizada, controle de acesso e gerenciamento de diretórios. Suporta conexões seguras através de TLS (LDAPS).


### 4. **ProFTPD**
- **Imagem**: `stilliard/pure-ftpd:hardened`
- **Container Name**: `proftpd_test`
- **Portas**: 
  - `21:21` (FTP)
  - `30000-30009:30000-30009` (FTP Passive Mode)
- **Ambiente**:
  - `PUBLICHOST=localhost`
  - `FTP_USER_NAME=anonymous`
  - `FTP_USER_PASS=anonymous`
  - `FTP_USER_HOME=/home/ftpusers/ftpuser`
- **Volumes**:
  - `./ftp_data:/home/ftpusers/ftpuser`
- **Rede**: `server_network`
- **Função**: Servidor FTP com acesso anônimo e diretório compartilhado para arquivos.

### O arquivo `nginx.conf`

```xml
Include /etc/proftpd/modules.conf


UseIPv6 off

<IfModule mod_ident.c>
  IdentLookups off
</IfModule>

ServerName "FTP Server"
ServerType standalone
DeferWelcome off

DefaultServer on
ShowSymlinks on

TimeoutNoTransfer 600
TimeoutStalled 600
TimeoutIdle 1200

DisplayLogin welcome.msg
DisplayChdir .message true
ListOptions "-l"

DenyFilter \*.*/

DefaultRoot ~


RequireValidShell off

Port 21


<IfModule mod_dynmasq.c>
</IfModule>

MaxInstances 30

User proftpd
Group nogroup

Umask 022 022

AllowOverwrite on

TransferLog /var/log/proftpd/xferlog
SystemLog /var/log/proftpd/proftpd.log

<IfModule mod_quotatab.c>
QuotaEngine off
</IfModule>

<IfModule mod_ratio.c>
Ratios off
</IfModule>

<IfModule mod_delay.c>
DelayEngine on
</IfModule>

<IfModule mod_ctrls.c>
ControlsEngine off
ControlsMaxClients 2
ControlsLog /var/log/proftpd/controls.log
ControlsInterval 5
ControlsSocket /var/run/proftpd/proftpd.sock
</IfModule>

<IfModule mod_ctrls_admin.c>
AdminControlsEngine off
</IfModule>

 <Anonymous ~ftp>
   User ftp
   Group nogroup

   UserAlias anonymous ftp

   RequireValidShell off

   MaxClients 10

   DisplayLogin welcome.msg
   DisplayChdir .message
   <Directory ~/share>
     <Limit READ WRITE>
       AllowAll
     </Limit>
   </Directory>
 </Anonymous>

Include /etc/proftpd/conf.d/
```

---------------------------------------

# 5. **Samba**
- **Imagem**: `dperson/samba`
- **Container Name**: `samba_server`
- **Portas**:
  - `139:139`
  - `445:445`
- **Ambiente**:
  - `USERID=1000`
  - `GROUPID=1000`
- **Volumes**:
  - `./samba_data:/mount`
  - `./publico:/samba/publico`
  - `./privaddo:/samba/privado`
- **Comando**:
  - `-u "admin;admin"`
  - `-s "public;/mount;yes;no;no;all"`
- **Rede**: `server_network`
- **Função**: Compartilhamento de arquivos SMB/CIFS com diretórios públicos e privados.

## O arquivo `smb.conf`

```shell
[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = debian
security = user
map to guest = bad user
dns proxy = no

[allusers]
comment = All Users
path = /home/shares/allusers
valid users = @users
force group = users
create mask = 0660
directory mask = 0771
writable = yes

[homes]
comment = Home Directories
browseable = no
valid users = %S
writable = yes
create mask = 0700
directory mask = 0700

[anonymous]
path = /home/shares/anonymous
force group = users
create mask = 0660
directory mask = 0771
browsable = yes
writable = yes
guest ok = yes
```

# Explicando algumas diretivas

## [global]
- **`workgroup`**: Define o nome do grupo de trabalho. Exemplo: `WORKGROUP`.
- **`server string`**: Descrição do servidor Samba. Exemplo: `Samba Server %v`.
- **`netbios name`**: Nome do servidor na rede. Exemplo: `debian`.
- **`security`**: Método de autenticação. `user` exige autenticação por nome de usuário e senha.
- **`map to guest`**: Mapeia usuários falhos para "guest" (usuário anônimo). Exemplo: `bad user`.
- **`dns proxy`**: Define se o Samba deve usar o proxy DNS. Exemplo: `no`.

## [allusers]
- **`path`**: Caminho do diretório compartilhado. Exemplo: `/home/shares/allusers`.
- **`valid users`**: Usuários ou grupos que têm permissão para acessar o compartilhamento. Exemplo: `@users`.
- **`create mask`**: Permissões para arquivos criados. Exemplo: `0660`.
- **`directory mask`**: Permissões para diretórios criados. Exemplo: `0771`.
- **`writable`**: Permite a gravação. Exemplo: `yes`.

## [homes]
- **`valid users`**: Usuários que podem acessar seus próprios diretórios. Exemplo: `%S` (usuário que está autenticado).
- **`browseable`**: Define se o compartilhamento é visível. Exemplo: `no`.
- **`writable`**: Permite a gravação. Exemplo: `yes`.

## [anonymous]
- **`path`**: Caminho do diretório público. Exemplo: `/home/shares/anonymous`.
- **`guest ok`**: Permite acesso sem autenticação. Exemplo: `yes`.
- **`browseable`**: Define se o compartilhamento é visível. Exemplo: `yes`.
- **`writable`**: Permite a gravação. Exemplo: `yes`.
- **`force group`**: Define o grupo para arquivos criados. Exemplo: `users`.

--------------------------------

## Redes

- **server_network**: Rede interna para comunicação entre servidores.
- **client_network**: Rede para comunicação com clientes externos.

## Volumes

- **openldap_data**: Volume persistente para dados do OpenLDAP.
