[cmdletbinding()]
param()

. $PSScriptRoot\..\..\lib\Initialize-Test.ps1

$called=$false
$testAssembly='**\testAssembly.dll'
Register-Mock Get-LocalizedString { $called=$true } -- -Key "No test assemblies found matching the pattern: '{0}'." -ArgumentList $testAssembly
Register-Mock Get-LocalizedString 
Register-Mock Write-Warning

$sourcesDirectory = 'c:\temp'
$distributedTaskContext = 'Some distributed task context'
Register-Mock Get-TaskVariable { $sourcesDirectory } -- -Context $distributedTaskContext -Name "Build.SourcesDirectory"

Register-Mock Find-Files { $false } -- -SearchPattern $testAssembly -RootFolder $sourcesDirectory

Register-Mock Convert-String { $true }

Register-Mock Publish-TestResults
Register-Mock Invoke-VsTest

$splat = @{
	'vsTestVersion' = 'vsTestVersion'
	'testAssembly' = $testAssembly 
	'testFiltercriteria' = 'testFiltercriteria' 
	'runSettingsFile' = 'runSettingsFile' 
	'codeCoverageEnabled' = 'codeCoverageEnabled'
	'pathtoCustomTestAdapters' = 'pathtoCustomTestAdapters'
	'overrideTestrunParameters' = 'overrideTestrunParameters'
	'otherConsoleOptions' = 'otherConsoleOptions'
	'testRunTitle' = 'testRunTitle'
	'platform' = 'platform'
	'configuration' = 'configuration'
	'publishRunAttachments' = 'publishRunAttachments'
	'runInParallel' = 'runInParallel'
}
& $PSScriptRoot\..\..\..\Tasks\VsTest\VsTest.ps1 @splat

Assert-WasCalled Find-Files -Times 1
Assert-WasCalled Publish-TestResults -Times 0
Assert-WasCalled Invoke-VsTest -Times 0
Assert-WasCalled Get-LocalizedString -Times 1
Assert-IsTrue $called