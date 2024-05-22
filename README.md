# Documentação do Projeto Final - CloudFormation

### Computação em Nuvem 6º Semestre - Engenharia de Computação, Insper
### Pedro Toledo Piza Civita - Maio de 2024

---

## Sumário

- [Documentação do Projeto Final - CloudFormation](#documentação-do-projeto-final---cloudformation)
    - [Computação em Nuvem 6º Semestre - Engenharia de Computação, Insper](#computação-em-nuvem-6º-semestre---engenharia-de-computação-insper)
    - [Pedro Toledo Piza Civita - Maio de 2024](#pedro-toledo-piza-civita---maio-de-2024)
  - [Sumário](#sumário)
  - [Objetivo](#objetivo)
  - [Diagrama da Arquitetura AWS](#diagrama-da-arquitetura-aws)
    - [Descrição da Arquitetura](#descrição-da-arquitetura)
  - [Decisões Técnicas](#decisões-técnicas)
    - [Escolha da Região](#escolha-da-região)
    - [Tipos de Instância](#tipos-de-instância)
    - [Configurações de Auto Scaling](#configurações-de-auto-scaling)
    - [Configurações de Segurança](#configurações-de-segurança)
    - [Balanceamento de Carga](#balanceamento-de-carga)
    - [Políticas de Escalabilidade](#políticas-de-escalabilidade)
    - [Banco de Dados NoSQL (DynamoDB)](#banco-de-dados-nosql-dynamodb)
  - [Pré-requisitos](#pré-requisitos)
    - [Conta na AWS](#conta-na-aws)
    - [Ferramentas Necessárias](#ferramentas-necessárias)
    - [Configuração de Segurança](#configuração-de-segurança)
    - [Dependências de Software](#dependências-de-software)
    - [Configuração do Ambiente](#configuração-do-ambiente)
    - [Repositório do Projeto](#repositório-do-projeto)
    - [Chave SSH](#chave-ssh)
    - [Configuração de Permissões IAM](#configuração-de-permissões-iam)
  - [Guia Passo a Passo](#guia-passo-a-passo)
    - [Configuração Inicial](#configuração-inicial)
    - [Detalhes do Script de Configuração](#detalhes-do-script-de-configuração)
    - [Testes de Carga com Locust](#testes-de-carga-com-locust)
    - [Destruir a Infraestrutura](#destruir-a-infraestrutura)
    - [Detalhes do Script de Limpeza](#detalhes-do-script-de-limpeza)
  - [Análise de Custo](#análise-de-custo)
    - [Estimativa de Custos Mensais](#estimativa-de-custos-mensais)
    - [Análise Real de Custos](#análise-real-de-custos)
  - [Repositório do Código](#repositório-do-código)
  - [Conclusão](#conclusão)
  - [Tempo Estimado para Execução das Ações](#tempo-estimado-para-execução-das-ações)
  - [Comandos Utilizados](#comandos-utilizados)
    - [Criação e Gerenciamento do Bucket S3](#criação-e-gerenciamento-do-bucket-s3)
    - [Gerenciamento da Stack CloudFormation](#gerenciamento-da-stack-cloudformation)
    - [Comandos de Teste e Monitoramento](#comandos-de-teste-e-monitoramento)
    - [Teste de Carga com Locust](#teste-de-carga-com-locust)
    - [Comandos de Stress Test](#comandos-de-stress-test)

---

## Objetivo

Provisionar uma arquitetura na AWS utilizando o CloudFormation, que englobe o uso de um Application Load Balancer (ALB), instâncias EC2 com Auto Scaling e um banco de dados DynamoDB. O objetivo é garantir alta disponibilidade, escalabilidade e desempenho da aplicação.

## Diagrama da Arquitetura AWS

![AWS Infrastructure](./img/awsInfrastructure.png)

### Descrição da Arquitetura

1. **VPC (Virtual Private Cloud)**:
   - **Definição**: A VPC é uma rede virtual dedicada à sua conta AWS. Ela permite o provisionamento de uma seção isolada logicamente da Nuvem AWS, onde você pode lançar recursos da AWS em uma rede virtual que você define.
   - **CidrBlock**: Configurado como 10.0.0.0/16, fornecendo até 65.536 endereços IP privados.
   - **Suporte a DNS**: DNS Support e DNS Hostnames estão habilitados para facilitar a resolução de nomes dentro da VPC.

2. **Subnets Públicas**:
   - **Número e Distribuição**: Três subnets públicas, cada uma em uma zona de disponibilidade diferente para garantir alta disponibilidade e tolerância a falhas.
   - **CIDR Blocks**:
     - Subnet 1: 10.0.1.0/24
     - Subnet 2: 10.0.2.0/24
     - Subnet 3: 10.0.3.0/24
   - **Configuração**: MapPublicIpOnLaunch está habilitado para permitir que instâncias EC2 nas subnets públicas obtenham endereços IP públicos automaticamente.

3. **Internet Gateway**:
   - **Função**: Permite a comunicação entre a VPC e a internet. É anexado à VPC para fornecer conectividade à internet para recursos dentro das subnets públicas.

4. **Route Table**:
   - **Propósito**: Define como os pacotes são roteados dentro da VPC. A tabela de rotas pública contém uma rota para o Internet Gateway, permitindo que o tráfego da internet seja roteado para as subnets públicas.
   - **Associações**: Cada subnet pública é associada à tabela de rotas pública, permitindo a comunicação de entrada e saída com a internet.

5. **Security Groups**:
   - **Função**: Atuam como um firewall virtual para instâncias EC2 e outros recursos. O Security Group define regras de tráfego de entrada e saída para controlar a segurança dos recursos.
   - **Configuração**:
     - Permitir tráfego HTTP (porta 80) de qualquer lugar.
     - Permitir tráfego HTTPS (porta 443) de qualquer lugar, se necessário.
     - Permitir tráfego SSH (porta 22) de um IP específico para segurança.

6. **Application Load Balancer (ALB)**:
   - **Propósito**: Distribui automaticamente o tráfego de entrada entre várias instâncias EC2 em múltiplas zonas de disponibilidade, garantindo alta disponibilidade e resiliência.
   - **Configuração**: 
     - Conectado às três subnets públicas.
     - Associado ao Security Group que permite tráfego HTTP e HTTPS.
     - Configurado para escutar na porta 80 e encaminhar o tráfego para o Target Group.

7. **Auto Scaling Group**:
   - **Função**: Garante que o número desejado de instâncias EC2 esteja em execução para lidar com a carga da aplicação. O Auto Scaling pode aumentar ou diminuir a capacidade conforme necessário com base em políticas definidas.
   - **Configuração**:
     - MinSize: 1, MaxSize: 5, DesiredCapacity: 3.
     - Associado ao Target Group do ALB.
     - Configurado com um Launch Configuration que especifica a AMI, tipo de instância e outras configurações de inicialização.
     - UserData script para instalar dependências e configurar a aplicação durante a inicialização da instância.

8. **DynamoDB**:
   - **Função**: Fornece um banco de dados NoSQL altamente disponível e escalável para armazenar dados da aplicação.
   - **Configuração**:
     - Tabela chamada ListaDeContatos.
     - Definida com um atributo de chave primária 'id' do tipo String (S).
     - Modo de cobrança configurado para PAY_PER_REQUEST, eliminando a necessidade de especificar capacidade de leitura/escrita provisionada.
     - Políticas de IAM associadas às instâncias EC2 para permitir acesso completo ao DynamoDB.

## Decisões Técnicas

### Escolha da Região

A região `us-east-1` foi selecionada devido aos custos mais baixos em comparação com outras regiões, além da proximidade com a base de usuários finais, o que contribui para uma melhor performance e redução da latência. Esta região também oferece uma ampla gama de serviços da AWS e suporte, tornando-a ideal para o projeto.

### Tipos de Instância

Instâncias do tipo `t2.micro` foram escolhidas para o ambiente de desenvolvimento e testes iniciais devido ao seu custo-benefício. Essas instâncias são elegíveis para o nível gratuito da AWS, o que proporciona economia significativa para projetos acadêmicos e experimentais. Além disso, as instâncias `t2.micro` são suficientemente potentes para suportar a carga de trabalho prevista durante a fase inicial do projeto.

### Configurações de Auto Scaling

Políticas de Auto Scaling foram configuradas com base em métricas de utilização da CPU para garantir alta disponibilidade e desempenho da aplicação:
- **Escalamento para cima:** Aumenta o número de instâncias quando a utilização da CPU ultrapassa 5%, permitindo que o sistema lide com aumentos repentinos de tráfego e carga.
- **Escalamento para baixo:** Reduz o número de instâncias quando a utilização da CPU cai abaixo de 1%, otimizando os custos operacionais ao ajustar automaticamente os recursos conforme a demanda diminui.

### Configurações de Segurança

Um Security Group foi implementado para garantir a segurança das instâncias EC2 e do DynamoDB:
- **Security Group para EC2:** Este grupo permite acesso à aplicação na porta 80 (HTTP) de qualquer lugar, garantindo que a aplicação web esteja acessível para todos os usuários. O acesso

 SSH na porta 22 é restrito ao IP específico do administrador (177.170.241.150/32), proporcionando uma camada adicional de segurança ao limitar o acesso administrativo.
- **Políticas de IAM:** As instâncias EC2 foram configuradas com uma role do IAM que permite acesso completo ao DynamoDB. Isso inclui ações como Scan, GetItem, PutItem, UpdateItem e DeleteItem na tabela `ListaDeContatos`, garantindo que as instâncias possam interagir com o banco de dados conforme necessário.

### Balanceamento de Carga

Um Application Load Balancer (ALB) foi configurado para distribuir automaticamente o tráfego de entrada entre as instâncias EC2 em múltiplas zonas de disponibilidade, garantindo alta disponibilidade e resiliência:
- **Configuração do ALB:** O ALB está configurado para escutar na porta 80 e redirecionar o tráfego para um Target Group que contém as instâncias EC2. Isso assegura que o tráfego seja distribuído de maneira uniforme e eficiente, proporcionando uma melhor experiência ao usuário final.
- **Monitoramento e Saúde:** O ALB está configurado para realizar verificações de saúde nas instâncias EC2, removendo automaticamente instâncias não saudáveis e redirecionando o tráfego para as instâncias saudáveis restantes.

### Políticas de Escalabilidade

Além do Auto Scaling baseado em CPU, políticas adicionais foram configuradas para ajustar a capacidade com base na utilização da CPU:
- **Política de Escalamento para Cima (ScaleUpPolicy):** Adiciona uma nova instância quando a utilização da CPU ultrapassa 5% por dois períodos consecutivos de 30 segundos.
- **Política de Escalamento para Baixo (ScaleDownPolicy):** Remove uma instância quando a utilização da CPU cai abaixo de 1% por dois períodos consecutivos de 30 segundos.

### Banco de Dados NoSQL (DynamoDB)

O DynamoDB foi escolhido como o banco de dados NoSQL devido à sua capacidade de escalabilidade, alta disponibilidade e baixo tempo de resposta:
- **Configuração da Tabela:** A tabela `ListaDeContatos` foi configurada com um esquema de chave primária simples utilizando o atributo `id` do tipo String. O modo de cobrança PAY_PER_REQUEST foi selecionado para facilitar a escalabilidade automática da capacidade de leitura e escrita com base na demanda.
- **Segurança:** O acesso ao DynamoDB é restrito às instâncias EC2 dentro do mesmo VPC, garantindo que apenas as instâncias autorizadas possam interagir com o banco de dados.

Essas decisões técnicas foram tomadas para garantir uma arquitetura robusta, segura e altamente disponível, capaz de escalar conforme necessário para atender às demandas da aplicação, enquanto otimiza os custos operacionais e mantém a segurança dos dados e recursos.

## Pré-requisitos

Para garantir o funcionamento correto do programa e a implantação bem-sucedida da infraestrutura descrita, são necessários os seguintes pré-requisitos:

### Conta na AWS

- **Conta AWS ativa:** Uma conta AWS com permissões suficientes para criar e gerenciar recursos como VPC, EC2, ALB, DynamoDB, IAM roles e políticas.
- **Chave de Acesso:** Chave de acesso (Access Key ID e Secret Access Key) configurada para permitir o uso do AWS CLI.

### Ferramentas Necessárias

- **AWS CLI:** A ferramenta de linha de comando AWS CLI deve estar instalada e configurada em seu ambiente local.
  - [Instruções de instalação da AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

- **CloudFormation:** Familiaridade com o AWS CloudFormation para criar e gerenciar stacks.
  - [Guia do usuário do AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)

- **Git:** Ferramenta de controle de versão Git instalada para clonar o repositório do projeto.
  - [Instruções de instalação do Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Configuração de Segurança

- **Par de Chaves SSH:** Um par de chaves SSH deve ser criado e configurado na AWS para permitir o acesso às instâncias EC2.
  - [Criação de pares de chaves no Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

### Dependências de Software

- **Python 3.x:** Certifique-se de que o Python 3.x e o pip (gerenciador de pacotes do Python) estão instalados em seu ambiente local.
  - [Instruções de instalação do Python](https://www.python.org/downloads/)

- **Bibliotecas Python:** As seguintes bibliotecas Python devem ser instaladas:
  - Flask
  - Boto3
  - Unzip (para descompactar arquivos)

  ```bash
  pip install flask boto3
  sudo apt-get install unzip
  ```

### Configuração do Ambiente

- **Configuração do AWS CLI:** Configure o AWS CLI com suas credenciais de acesso.

  ```bash
  aws configure
  ```

  Insira o Access Key ID, Secret Access Key, região padrão (`us-east-1`), e o formato de saída padrão (`json`).

### Repositório do Projeto

- **Clonagem do Repositório:** Clone o repositório do projeto a partir do GitHub.

  ```bash
  git clone https://github.com/pedrocivita/pedrotpcProjetoCloudFormation
  cd pedrotpcProjetoCloudFormation
  ```

### Chave SSH

- **Configuração da Chave SSH:** Certifique-se de que a chave SSH necessária está disponível em seu ambiente local e é a mesma configurada no par de chaves AWS.

```yaml
KeyName: pedrotpcKeyPair
```

### Configuração de Permissões IAM

- **Permissões IAM:** A role do IAM deve ter permissões adequadas para acessar DynamoDB, S3, CloudWatch, e outros serviços necessários.

Com esses pré-requisitos atendidos, você estará pronto para implantar a infraestrutura e a aplicação utilizando o AWS CloudFormation e outras ferramentas descritas.

## Guia Passo a Passo

### Configuração Inicial

1. **Clone o Repositório do GitHub e Acesse o Diretório do Projeto:**

   ```bash
   git clone https://github.com/pedrocivita/pedrotpcProjetoCloudFormation
   cd pedrotpcProjetoCloudFormation
   ```

2. **Dar Permissão de Execução aos Scripts (Linux):**

   ```bash
   chmod +x scriptsSetupCleanup/setup.sh scriptsSetupCleanup/cleanup.sh
   ```

3. **Executar o Script de Configuração:**

   Para Windows:
   ```powershell
   .\scriptsSetupCleanup\setup.ps1
   ```

   Para Linux:
   ```bash
   ./scriptsSetupCleanup/setup.sh
   ```

### Detalhes do Script de Configuração

O script de configuração realiza as seguintes etapas:

1. **Criação de um Bucket S3:**
   ```bash
   aws s3 mb s3://bucket-do-civita --region us-east-1
   ```

2. **Upload dos Arquivos da Aplicação para o Bucket S3:**
   ```bash
   aws s3 cp appFiles/app.py s3://bucket-do-civita/app.py
   aws s3 cp appFiles/dynamo_service.py s3://bucket-do-civita/dynamo_service.py
   aws s3 cp appFiles/home.html s3://bucket-do-civita/home.html
   ```

3. **Validação do Template CloudFormation:**
   ```bash
   aws cloudformation validate-template --template-body file://full-stack.yaml
   ```

4. **Criação da Stack CloudFormation:**
   ```bash
   aws cloudformation create-stack --stack-name StackDoCivitaApp --template-body file://full-stack.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
   ```

### Testes de Carga com Locust

1. **Instalar e Executar o Locust:**

   ```bash
   pip install locust
   locust -f locustfile.py
   ```

2. **Acessar a Interface do Locust:**
   
   Abra o navegador e acesse `http://localhost:8089`.

3. **Configurar e Iniciar os Testes de Carga:**

   Configure o número de usuários simulados e a taxa de spawn (usuários/segundo). Inicie o teste e observe o comportamento da sua aplicação sob carga.

### Destruir a Infraestrutura

1. **Executar o Script de Limpeza:**

   Para Windows:
   ```powershell
   .\scriptsSetupCleanup\cleanup.ps1
   ```

   Para Linux:
   ```bash
   ./scriptsSetupCleanup/cleanup.sh
   ```

### Detalhes do Script de Limpeza

O script de limpeza realiza as seguintes etapas:

1. **Deletar a Stack CloudFormation:**
   ```bash
   aws cloudformation delete-stack --stack-name StackDoCivitaApp
   ```

2. **Aguardar a Deleção da Stack:**
   ```powershell
   while ((aws cloudformation describe-stacks --stack-name StackDoCivitaApp).Stacks[0].StackStatus -eq 'DELETE_IN_PROGRESS') {
       Start-Sleep -Seconds 30
   }
   ```

3. **Deletar o Bucket S3:**
   ```bash
   aws s3 rb s3://bucket-do-civita --force
   ```

## Análise de Custo



### Estimativa de Custos Mensais

Foi utilizada a Calculadora de Custos da AWS para estimar os custos mensais da arquitetura. Os principais componentes incluem:

- **EC2 Instances:** Utilização de instâncias t2.micro para o Auto Scaling Group.
- **Application Load Balancer:** Para distribuir o tráfego.
- **DynamoDB:** Tabela provisionada para armazenamento dos contatos.

| Recurso                    | Custo Estimado Mensal |
|----------------------------|-----------------------|
| EC2 Instances              | $XX.XX                |
| Application Load Balancer  | $XX.XX                |
| DynamoDB                   | $XX.XX                |
| **Total**                  | $XX.XX                |

### Análise Real de Custos

Após a implementação e o teste da infraestrutura, foram verificados os custos reais utilizando as tags configuradas. Os custos reais foram:

| Recurso                    | Custo Real Mensal     |
|----------------------------|-----------------------|
| EC2 Instances              | $YY.XX                |
| Application

 Load Balancer  | $YY.XX                |
| DynamoDB                   | $YY.XX                |
| **Total**                  | $YY.XX                |

As diferenças entre as estimativas e os custos reais foram principalmente devido a [justificativa].

## Repositório do Código

O código do CloudFormation e os scripts utilizados estão disponíveis no seguinte repositório do GitHub: [pedrotpcProjetoCloudFormation](https://github.com/pedrocivita/pedrotpcProjetoCloudFormation).

## Conclusão

Este projeto demonstrou a capacidade de provisionar e gerenciar uma arquitetura na AWS utilizando o CloudFormation, garantindo alta disponibilidade e escalabilidade através do uso de ALB, Auto Scaling Group e DynamoDB. A análise de custo e os testes de carga forneceram insights valiosos sobre o desempenho e os custos da infraestrutura, permitindo otimizações futuras.

## Tempo Estimado para Execução das Ações

| Ação                              | Tempo Estimado            |
|-----------------------------------|---------------------------|
| Criação do Bucket S3              | 1-2 minutos               |
| Upload dos Arquivos para o S3     | 1-2 minutos               |
| Validação do Template             | 1 minuto                  |
| Criação da Stack CloudFormation   | 5-10 minutos              |
| Execução do Script de Limpeza     | 3-5 minutos               |
| Instalação e Configuração do Locust| 5 minutos                 |

## Comandos Utilizados

### Criação e Gerenciamento do Bucket S3

- **Criar bucket:**
  ```bash
  aws s3 mb s3://bucket-do-civita --region us-east-1
  ```

- **Upload do app 'app.py':**
  ```bash
  aws s3 cp appFiles/app.py s3://bucket-do-civita/app.py
  ```

- **Upload dos serviços DynamoDB:**
  ```bash
  aws s3 cp appFiles/dynamo_service.py s3://bucket-do-civita/dynamo_service.py
  ```

- **Upload do 'home.html':**
  ```bash
  aws s3 cp appFiles/home.html s3://bucket-do-civita/home.html
  ```

- **Deletar bucket:**
  ```bash
  aws s3 rb s3://bucket-do-civita --force
  ```

### Gerenciamento da Stack CloudFormation

- **Validar template:**
  ```bash
  aws cloudformation validate-template --template-body file://full-stack.yaml
  ```

- **Criar stack:**
  ```bash
  aws cloudformation create-stack --stack-name StackDoCivitaApp --template-body file://full-stack.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
  ```

- **Atualizar stack:**
  ```bash
  aws cloudformation update-stack --stack-name StackDoCivitaApp --template-body file://full-stack.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
  ```

- **Deletar stack:**
  ```bash
  aws cloudformation delete-stack --stack-name StackDoCivitaApp
  ```

### Comandos de Teste e Monitoramento

- **Verificar status do servidor web:**
  ```bash
  sudo systemctl status webserver.service
  ```

- **Iniciar servidor web:**
  ```bash
  sudo systemctl start webserver.service
  ```

- **Checar logs para erros:**
  ```bash
  sudo journalctl -u webserver.service
  ```

- **Verificar a saída do log de UserData:**
  ```bash
  cat /var/log/user-data.log
  ```

### Teste de Carga com Locust

- **Instalar Locust:**
  ```bash
  pip install locust
  ```

- **Rodar Locust:**
  ```bash
  locust -f locustfile.py
  ```

- **Acessar a interface do Locust:**
  Abra o navegador e acesse `http://localhost:8089`.

### Comandos de Stress Test

- **Instalar ferramenta de stress:**
  ```bash
  sudo yum install -y stress
  ```

- **Executar stress test:**
  ```bash
  stress --cpu 2 --timeout 300
  ```