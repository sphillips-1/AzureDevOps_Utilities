# List all pipeline names in a project

$org = ''
$project = ''

az pipelines build definition list --org https://dev.azure.com/$org/ --project $project --query [*].name
