# API Blockchain Contract — Serviço intermediado por smart contracts (Web3j + Spring + MySQL + Docker)

Objetivo
- Construir uma API para contratação de serviços virtuais intermediada por blockchain (Ethereum Sepolia), onde:
  - On-chain: smart contracts armazenam o hash do contrato, partes (contratante/contratado), valores, prazos e status, garantindo imutabilidade e transparência.
  - Off-chain: informações derivadas e operacionais são persistidas em MySQL para consultas eficientes e integrações.
  - API: expõe operações para criar/atualizar consultar contratos e usuários, orquestra deploy/interação com os smart contracts via Web3j.

Arquitetura (visão atual do repo)
- Módulo único Spring Boot: [api.blockchain.contracts](api.blockchain.contracts)
- Smart contracts Solidity: [src/main/solidity](api.blockchain.contracts/src/main/solidity)
- Docker do app: [api.blockchain.contracts/Dockerfile](api.blockchain.contracts/Dockerfile)
- Orquestração (Compose): [api.blockchain.contracts/docker-compose.yml](api.blockchain.contracts/docker-compose.yml)
- Configuração Spring: [application.properties](api.blockchain.contracts/src/main/resources/application.properties)
- Ponto de entrada: [`Application`](api.blockchain.contracts/src/main/java/edu/ifba/saj/ads/api/blockchain/contracts/Application.java)
- Dockerfile na raiz: [Dockerfile](Dockerfile) — atualmente vazio e não utilizado

Estrutura de pastas (essencial)
```
api-blockchain-contract/
├── api.blockchain.contracts/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/edu/ifba/saj/ads/api/blockchain/contracts/Application.java
│   │   │   ├── resources/application.properties
│   │   │   └── solidity/
│   │   │       ├── ServiceAgreement.sol
│   │   │       ├── ServiceAgreementFactory.sol
│   │   │       └── UserRegistry.sol
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── pom.xml
└── Dockerfile   (vazio, não usado)
```

Smart Contracts (Solidity)
- [ServiceAgreement.sol](api.blockchain.contracts/src/main/solidity/ServiceAgreement.sol)
  - Importa Ownable (OpenZeppelin).
  - Armazena: serviceProvider, client, agreedValue, startDate, deliveryDate, serviceDescription, isCompleted, contractHash, creationTimestamp.
  - Controle de propriedade e fluxo básico do acordo.

- [ServiceAgreementFactory.sol](api.blockchain.contracts/src/main/solidity/ServiceAgreementFactory.sol)
  - Mantém lista de `ServiceAgreement`.
  - `owner` autorizado a criar novos acordos com parâmetros do serviço.
  - Prevê atualização (funções adicionais em progresso).

- [UserRegistry.sol](api.blockchain.contracts/src/main/solidity/UserRegistry.sol)
  - Registro simples de usuários com nome, info sensível (off-chain deve ser criptografada), wallet e timestamp.
  - Consulta por wallet.

Camada Java/Spring Boot
- Ponto de entrada: [`Application`](api.blockchain.contracts/src/main/java/edu/ifba/saj/ads/api/blockchain/contracts/Application.java)
- Principais dependências no [pom.xml](api.blockchain.contracts/pom.xml):
  - Spring Boot: web, data-jpa, security, devtools
  - Banco: `mysql-connector-j`
  - Blockchain: `org.web3j:core:4.14.0`
  - Testes: `spring-boot-starter-test`, `spring-security-test`
- Observações importantes:
  - Java no POM está setado como `24`. O Dockerfile do app usa Temurin 17. Recomenda-se alinhar para Java 17 ou 21 (LTS) para evitar falhas de build/runtime.
  - Há configuração do plugin `web3j-maven-plugin` no `<build>`, mas a seção está incompleta (tags de fechamento e diretórios). Ajustar para gerar wrappers Java a partir dos `.sol`.
  - Os imports Solidity usam OpenZeppelin (`@openzeppelin/...`). É necessário garantir o caminho/remapping no processo de compilação Solidity do plugin (ex.: instalar via npm e configurar include path ou copiar os contratos OZ para um diretório resolvível).

Configuração da aplicação
- [application.properties](api.blockchain.contracts/src/main/resources/application.properties)
  - Datasource via Compose:
    - `spring.datasource.url=jdbc:mysql://mysql-db:3306/servicedb?useSSL=false&serverTimezone=UTC`
    - `spring.datasource.username=user`
    - `spring.datasource.password=${DB_PASSWORD}` (via .env)
  - JPA:
    - `spring.jpa.hibernate.ddl-auto=validate` (exige que o schema exista — ideal integrar Flyway)
  - Web3j:
    - `web3j.client-address=http://geth-node:8545` (endpoint do nó Geth no Compose)

Docker e Orquestração
- App (Spring Boot)
  - Dockerfile: [api.blockchain.contracts/Dockerfile](api.blockchain.contracts/Dockerfile)
    - Fase build: Maven + Temurin 17, `mvn clean package -DskipTests`
    - Fase runtime: Temurin 17 JRE, expõe 8080
- Compose: [api.blockchain.contracts/docker-compose.yml](api.blockchain.contracts/docker-compose.yml)
  - Serviços:
    - `app`
      - `build: .` (usa o Dockerfile do módulo)
      - Porta `8080:8080`
      - Variáveis:
        - `SPRING_DATASOURCE_URL=jdbc:mysql://mysql-db:3306/servicedb`
        - `SPRING_DATASOURCE_USERNAME=user`
        - `SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}`
        - `WEB3J_CLIENT_ADDRESS=http://geth-node:8545`
      - depends_on: `mysql-db`, `geth-node`
    - `mysql-db`
      - Imagem `mysql:8.0`
      - DB: `servicedb`, user `user`
      - Senhas via `${DB_PASSWORD}` (arquivo `.env` no mesmo diretório do compose)
      - Volume `mysql-data:/var/lib/mysql`
    - `geth-node`
      - Imagem oficial `ethereum/client-go:stable`
      - Comando (Sepolia, HTTP 8545, sync light, CORS liberado):
        ```
        --sepolia --http --http.addr "0.0.0.0" --http.port 8545 \
        --http.api "eth,net,web3" --http.corsdomain "*" --syncmode "light"
        ```
      - Porta `8545:8545`
      - Volume `geth-data:/root/.ethereum`
  - Volumes: `mysql-data`, `geth-data`
  - Network: `app-network`

Importante sobre o .BAT do Geth
- Atualmente o Compose usa a imagem Linux oficial do Geth, o que é o caminho mais estável em Docker Desktop (Windows).
- Se for obrigatório “rodar o Geth através do .bat”, mantenha um `start_geth.bat` para uso local (fora do Docker), ou crie uma imagem Windows (Windows Containers) que invoque o `.bat`. Isso exige alternar Docker Desktop para Windows containers e ajustar o Compose — não recomendado para portabilidade. O repositório atual não contém esse `.bat`.

Execução (Windows Powershell)
1) Entre na pasta do módulo com o compose:
```
cd api.blockchain.contracts
```
2) Crie um arquivo `.env` com a senha:
```
echo DB_PASSWORD=SuaSenhaForteAqui > .env
```
3) Suba os serviços:
```
docker compose up --build
```
- App: http://localhost:8080
- Geth RPC: http://localhost:8545
- MySQL: localhost:3306 (dentro da rede, `mysql-db:3306`)

Geração de wrappers Web3j (planejado)
- Objetivo: compilar os `.sol` e gerar classes Java em `edu.ifba.saj.ads.api.blockchain.contracts.generated`.
- Passos a concluir no [pom.xml](api.blockchain.contracts/pom.xml):
  - Fechar corretamente a configuração do plugin `web3j-maven-plugin`.
  - Definir `soliditySourceFiles.directory` para `src/main/solidity`.
  - Definir `outputDirectory` (ex.: `${project.build.directory}/generated-sources/web3j`) e marcar como `sourceDirectory`.
  - Configurar resolução de imports do OpenZeppelin.
- Após corrigir, rodar:
```
mvn clean package
```
ou
```
mvn web3j:generate-sources
```

Banco de dados e migrações
- `spring.jpa.hibernate.ddl-auto=validate` exige schema criado previamente.
- Recomenda-se adicionar Flyway:
  - Dependência no POM.
  - Scripts em `src/main/resources/db/migration` (ex.: `V1__init.sql` com tabelas para contratos/usuários off-chain).
- Em testes, considerar H2 (modo MySQL) ou Testcontainers.

Estado atual vs. Próximos passos
- Implementado
  - Estrutura do projeto Spring Boot e ponto de entrada.
  - Contratos Solidity base: ServiceAgreement, ServiceAgreementFactory, UserRegistry.
  - Docker do app; Compose com `app`, `mysql-db` e `geth-node`.
  - Configuração básica do datasource e endpoint Web3j.
- Falta/ajustar
  - Corrigir Java para 17 ou 21 no [pom.xml](api.blockchain.contracts/pom.xml) para alinhar ao Dockerfile.
  - Finalizar `web3j-maven-plugin` e a compilação dos contratos (incluindo OpenZeppelin).
  - Adicionar Flyway e migrações iniciais (ddl-auto=validate).
  - Implementar camada de domínio: entidades JPA, repositórios, serviços e (futuramente) controladores REST.
  - Segurança: `spring-boot-starter-security` está presente, mas sem configuração (planejar JWT/OAuth2).
  - Testes: criar perfil de teste (H2/Testcontainers) para o contexto subir sem MySQL/Geth reais.
  - Definir estratégia de secrets (.env para DB, RPC keys se necessário).
  - Revisar Dockerfile na raiz (está vazio; remover ou dar propósito).

Como a IA deve usar este contexto
- Considerar a rede alvo (Sepolia) e endpoints do Geth no Compose (`geth-node:8545`).
- Sugerir código de integração Web3j para:
  - Deploy de `ServiceAgreementFactory` e criação/consulta de `ServiceAgreement`.
  - Mapeamento dos dados on-chain para entidades off-chain.
- Propor schema SQL e migrações Flyway consistentes com o modelo on-chain.
- Gerar wrappers Web3j somente após corrigir a configuração do plugin no POM.
- Manter compatibilidade de versão: Java 17/21, Spring Boot 3.5.x, Web3j 4.14.0.
- Sugerir testes com Testcontainers (MySQL + Geth simulado via Ganache/Hardhat se necessário) ou H2 para repositórios.

Referências rápidas
- App Dockerfile: [api.blockchain.contracts/Dockerfile](api.blockchain.contracts/Dockerfile)
- Compose: [api.blockchain.contracts/docker-compose.yml](api.blockchain.contracts/docker-compose.yml)
- Propriedades: [application.properties](api.blockchain.contracts/src/main/resources/application.properties)
- POM: [pom.xml](api.blockchain.contracts/pom.xml)
- Solidity:
  - [ServiceAgreement.sol](api.blockchain.contracts/src/main/solidity/ServiceAgreement.sol)
  - [ServiceAgreementFactory.sol](api.blockchain.contracts/src/main/solidity/ServiceAgreementFactory.sol)