[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName
)

#requires -Module Az.Accounts,Az.Resources

$templateARM = Get-Content 'server.json' -Raw -ErrorAction SilentlyContinue
$template = ConvertFrom-Json -InputObject $templateARM -ErrorAction SilentlyContinue

describe 'Template validation' {

    It 'Template ARM File Exists' {
        Test-Path 'server.json' -Include '*.json' | Should Be $true
    }

    It 'Is a valid JSON file' {
        $templateARM | ConvertFrom-Json -ErrorAction SilentlyContinue | Should Not Be $Null
    }

    It "Contains all required elements" {
        $Elements = '$schema',
        'contentVersion',
        'outputs',
        'parameters',
        'resources',
        'variables'                               
        $templateProperties = $template | Get-Member -MemberType NoteProperty | % Name
        $templateProperties | Should Be $Elements
    }

    it 'template passes validation check' {
        $parameters = @{
            TemplateFile      = 'server.json'
            ResourceGroupName = $ResourceGroupName
            adminUsername     = 'admin'
            adminPassword     = (ConvertTo-SecureString -String 'testing' -AsPlainText -Force)
            vmName            = 'TESTING'
        }
        (Test-AzResourceGroupDeployment @parameters).Details | should -Benullorempty
    }


    
}
