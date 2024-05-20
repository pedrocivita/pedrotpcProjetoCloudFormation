# Documentação do Projeto Final - CloudFormation
### Computação em Nuvem 6o Semestre - Engenharia de Computação, Insper
### Pedro Toledo Piza Civita - Maio de 2024

## Objetivo

Provisionar uma arquitetura na AWS utilizando o CloudFormation, que englobe o uso de um Application Load Balancer (ALB), instâncias EC2 com Auto Scaling e um banco de dados DynamoDB. O objetivo é garantir alta disponibilidade, escalabilidade e desempenho da aplicação.

## Diagrama da Arquitetura AWS

[Insira aqui um diagrama da arquitetura AWS que você criou. Você pode usar ferramentas como draw.io ou Lucidchart para criar este diagrama.]

## Decisões Técnicas

### Escolha da Região
Foi escolhida a região `us-east-1` devido aos custos mais baixos e à proximidade com os usuários finais.

### Tipos de Instância
Foram utilizadas instâncias `t2.micro` devido ao seu custo-benefício para o ambiente de desenvolvimento e testes iniciais.

### Configurações de Auto Scaling
Foram utilizadas de escalabilidade baseadas em métricas de CPU para garantir alta disponibilidade e desempenho. A política de escala para cima é acionada quando a utilização da CPU ultrapassa 5%, e a política de escala para baixo é acionada quando a utilização da CPU cai abaixo de 1%.

### Configurações de Segurança
Foram implementados Security Groups para restringir o acesso às instâncias EC2 e ao DynamoDB.

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

Este projeto demonstrou a capacidade de provisionar e gerenciar uma arquitetura na AWS utilizando o CloudFormation, garantindo alta disponibilidade e escalabilidade através do uso de ALB, Auto Scaling Group e DynamoDB. A análise de custo e os testes de carga forneceram insights valiosos sobre o desempenho e os custos da infraestrutura, permitindo otimizações futuras.
