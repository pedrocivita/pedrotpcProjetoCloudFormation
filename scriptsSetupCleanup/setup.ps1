# setup.ps1
# Script to set up AWS resources on Windows

# Configurações iniciais
$bucketName = "bucket-do-civita"
$stackName = "StackDoCivitaApp"
$templateFile = "full-stack.yaml"
$locustFile = "locustfile.py"

# Criar bucket S3
aws s3 mb "s3://$bucketName" --region us-east-1
Start-Sleep -Seconds 5

# Fazer upload dos arquivos necessários para o S3
aws s3 cp appFiles/app.py "s3://$bucketName/app.py"
Start-Sleep -Seconds 3
aws s3 cp appFiles/dynamo_service.py "s3://$bucketName/dynamo_service.py"
Start-Sleep -Seconds 3
aws s3 cp appFiles/home.html "s3://$bucketName/home.html"
Start-Sleep -Seconds 3

# Validar template CloudFormation
aws cloudformation validate-template --template-body "file://$templateFile"
Start-Sleep -Seconds 3

# Criar stack no CloudFormation
$stackId = (aws cloudformation create-stack --stack-name $stackName --template-body "file://$templateFile" --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND).StackId
Start-Sleep -Seconds 10

# Esperar a stack ser criada
while ($true) {
    $stackStatus = (aws cloudformation describe-stacks --stack-name $stackName | ConvertFrom-Json).Stacks[0].StackStatus
    if ($stackStatus -eq "CREATE_COMPLETE") {
        break
    }
    elseif ($stackStatus -match "FAILED|ROLLBACK") {
        Write-Error "Stack creation failed with status: $stackStatus"
        exit 1
    }
    Write-Output "Waiting for stack creation... Current status: $stackStatus"
    Start-Sleep -Seconds 20
}

# Obter o DNS Name do ALB
$stackOutput = aws cloudformation describe-stacks --stack-name $stackName | ConvertFrom-Json
$albDnsName = ($stackOutput.Stacks[0].Outputs | Where-Object { $_.OutputKey -eq "ALBDNSName" }).OutputValue

# Atualizar o locustfile.py com o DNS do ALB
(Get-Content $locustFile) -replace 'host = .*', "host = `"http://$albDnsName`"" | Set-Content $locustFile

Write-Output "Setup complete. ALB DNS Name: $albDnsName"