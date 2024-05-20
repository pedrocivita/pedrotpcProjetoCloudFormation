#!/bin/bash
# setup.sh
# Script to set up AWS resources on Linux

# Configurações iniciais
bucketName="bucket-do-civita"
stackName="StackDoCivitaApp"
templateFile="full-stack.yaml"
locustFile="locustfile.py"

# Criar bucket S3
aws s3 mb s3://$bucketName --region us-east-1
sleep 5

# Fazer upload dos arquivos necessários para o S3
aws s3 cp appFiles/app.py s3://$bucketName/app.py
sleep 3
aws s3 cp appFiles/dynamo_service.py s3://$bucketName/dynamo_service.py
sleep 3
aws s3 cp appFiles/home.html s3://$bucketName/home.html
sleep 3

# Validar template CloudFormation
aws cloudformation validate-template --template-body file://$templateFile
sleep 3

# Criar stack no CloudFormation
stackId=$(aws cloudformation create-stack --stack-name $stackName --template-body file://$templateFile --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --query [StackId] --output text)
sleep 10

# Esperar a stack ser criada
while true; do
    stackStatus=$(aws cloudformation describe-stacks --stack-name $stackName --query "Stacks[0].StackStatus" --output text)
    if [[ "$stackStatus" == "CREATE_COMPLETE" ]]; then
        break
    elif [[ "$stackStatus" =~ "FAILED|ROLLBACK" ]]; then
        echo "Stack creation failed with status: $stackStatus"
        exit 1
    fi
    echo "Waiting for stack creation... Current status: $stackStatus"
    sleep 20
done

# Obter o DNS Name do ALB
albDnsName=$(aws cloudformation describe-stacks --stack-name $stackName --query "Stacks[0].Outputs[?OutputKey=='ALBDNSName'].OutputValue" --output text)

# Atualizar o locustfile.py com o DNS do ALB
sed -i "s|host = .*|host = \"http://$albDnsName\"|" $locustFile

echo "Setup complete. ALB DNS Name: $albDnsName"