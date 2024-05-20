# cleanup.ps1
# Script to clean up AWS resources on Windows

# Configurações iniciais
$bucketName = "bucket-do-civita"
$stackName = "StackDoCivitaApp"

# Deletar stack no CloudFormation
aws cloudformation delete-stack --stack-name $stackName
Start-Sleep -Seconds 5

# Esperar a stack ser deletada
while ($true) {
    try {
        $stackStatus = (aws cloudformation describe-stacks --stack-name $stackName | ConvertFrom-Json).Stacks[0].StackStatus
    } catch {
        break
    }
    Write-Output "Waiting for stack deletion... Current status: $stackStatus"
    Start-Sleep -Seconds 20
}

# Apagar bucket S3 e seu conteúdo
aws s3 rb "s3://$bucketName" --force
Start-Sleep -Seconds 5

Write-Output "Cleanup complete."
