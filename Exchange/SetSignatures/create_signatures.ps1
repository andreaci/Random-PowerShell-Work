$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

#set folder location for files, the folder must already exist
$cur_path = Get-Location 
$mailboxes = Import-Csv  "$($cur_path)\signatures_data.csv"

$mailboxes | foreach {

	$template = "$($_.TEMPLATE)"

	$user = "$($_.USER)"
	$full_name = "$($_.NAME)"
	$role = "$($_.ROLE)"
	$tel = "$($_.TEL)"	
	$cell = "$($_.CELL)"	
	$skype = "$($_.SKYPE)"	
	$mail = "$($_.MAIL)"	

	if ($tel.trim() -ne '') {
    	$tel=' - Tel: ' + $tel;
	}	
	if ($cell.trim() -ne '') {
    	$cell=' - Cell: ' + $cell;
	}	
	if ($skype.trim() -ne '') {
    	$skype=' - Skype: ' + $skype;
	}	


	$template_file = "$($cur_path)\$template.html"
	$output_file_html = "$($cur_path)\data\$($user).html"

	$template_text = Get-Content -Path $template_file
	$template_text = $template_text -replace '%%NAME%%', $full_name
	$template_text = $template_text -replace '%%ROLE%%', $role
	$template_text = $template_text -replace '%%MAIL%%', $mail
	$template_text = $template_text -replace '%%TEL%%', $tel
	$template_text = $template_text -replace '%%CELL%%', $cell
	$template_text = $template_text -replace '%%SKYPE%%', $skype


	$template_file_txt = "$($cur_path)\$template.txt"
	$output_file_txt = "$($cur_path)\data\$($user).txt"
	
	$template_text_txt = Get-Content -Path $template_file_txt
	$template_text_txt = $template_text_txt -replace '%%NAME%%', $full_name
	$template_text_txt = $template_text_txt -replace '%%ROLE%%', $role
	$template_text_txt = $template_text_txt -replace '%%MAIL%%', $mail
	$template_text_txt = $template_text_txt -replace '%%TEL%%', $tel
	$template_text_txt = $template_text_txt -replace '%%CELL%%', $cell
	$template_text_txt = $template_text_txt -replace '%%SKYPE%%', $skype


	Set-Content -Path $output_file_html -Value $template_text
	Set-Content -Path $output_file_txt -Value $template_text_txt
		
	Write-Host "Now attempting to set signature for " $_.user
	set-mailboxmessageconfiguration -identity $_.user -signaturehtml (get-content $output_file_html) -signaturetext $txt_signature -autoaddsignature $true
}