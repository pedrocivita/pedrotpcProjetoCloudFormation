# Documentação do Projeto Final - CloudFormation

## Computação em Nuvem 6º Semestre - Engenharia de Computação, Insper
## Pedro Toledo Piza Civita - Maio de 2024

---

## Sumário

- [Documentação do Projeto Final - CloudFormation](#documentação-do-projeto-final---cloudformation)
  - [Objetivo](#objetivo)
  - [Diagrama da Arquitetura AWS](#diagrama-da-arquitetura-aws)
  - [Decisões Técnicas](#decisões-técnicas)
    - [Escolha da Região](#escolha-da-região)
    - [Tipos de Instância](#tipos-de-instância)
    - [Configurações de Auto Scaling](#configurações-de-auto-scaling)
    - [Configurações de Segurança](#configurações-de-segurança)
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

Este projeto tem como objetivo provisionar uma arquitetura na AWS utilizando o CloudFormation, que engloba o uso de um Application Load Balancer (ALB), instâncias EC2 com Auto Scaling e um banco de dados DynamoDB. A meta é garantir alta disponibilidade, escalabilidade e desempenho da aplicação.

## Diagrama da Arquitetura AWS

![Diagrama da Arquitetura](link_do_diagrama)

> *Insira aqui um diagrama detalhado da arquitetura AWS que você criou. Ferramentas como draw.io ou Lucidchart são recomendadas para criar este diagrama.*

## Decisões Técnicas

### Escolha da Região

A região `us-east-1` foi escolhida devido aos custos mais baixos e à proximidade com os usuários finais, garantindo melhor performance e redução de latência.

### Tipos de Instância

Optou-se por instâncias `t2.micro` para o ambiente de desenvolvimento e testes iniciais devido ao seu custo-benefício. Estas instâncias são elegíveis para o nível gratuito da AWS, o que é vantajoso para projetos acadêmicos e experimentais.

### Configurações de Auto Scaling

Foram configuradas políticas de Auto Scaling baseadas em métricas de CPU para garantir alta disponibilidade e desempenho:
- **Escalamento para cima:** Aumenta o número de instâncias quando a utilização da CPU ultrapassa 50%.
- **Escalamento para baixo:** Reduz o número de instâncias quando a utilização da CPU cai abaixo de 10%.

### Configurações de Segurança

Implementamos Security Groups para restringir o acesso às instâncias EC2 e ao DynamoDB:
- **EC2 Security Group:** Permite acesso apenas na porta 80 (HTTP) e 22 (SSH) de IPs específicos.
- **DynamoDB Security Group:** Restringe acesso para apenas instâncias EC2 dentro do mesmo VPC.

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
| Application Load Balancer  | $YY.XX                |
| DynamoDB                   | $YY.XX                |
| **Total**                  | $YY.XX                |

As diferenças entre as estimativas e os custos reais foram principalmente devido a [justificativa].

## Repositório do Código

O código do CloudFormation e os scripts utilizados estão disponíveis no seguinte repositório do GitHub: [pedrotpcProjetoCloudFormation](https://github.com/pedrocivita/pedrotpcProjetoCloudFormation).

## Conclusão

Este projeto demonstrou a capacidade de provisionar e gerenciar uma arquitetura na AWS utilizando o CloudFormation, garantindo alta disponibilidade e escalabilidade através do uso de ALB, Auto Scaling Group e DynamoDB. A análise de custo

 e os testes de carga forneceram insights valiosos sobre o desempenho e os custos da infraestrutura, permitindo otimizações futuras.

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
