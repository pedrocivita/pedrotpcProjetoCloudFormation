#!/bin/bash
# cleanup.sh
# Script to clean up AWS resources on Linux

# Configurações iniciais
bucketName="bucket-do-civita"
stackName="StackDoCivitaApp"

# Deletar stack no CloudFormation
aws cloudformation delete-stack --stack-name $stackName
sleep 5

# Esperar a stack ser deletada
while true; do
    stackStatus=$(aws cloudformation describe-stacks --stack-name $stackName --query "Stacks[0].StackStatus" --output text 2>/dev/null)
    if [[ -z "$stackStatus" ]]; then
        break
    fi
    echo "Waiting for stack deletion... Current status: $stackStatus"
    sleep 20
done

# Apagar bucket S3 e seu conteúdo
aws s3 rb s3://$bucketName --force
sleep 5

echo "Cleanup complete."
