function GenerateForm {
###############################################################################################################
# Version History: 
# 
# 1.1 - 18/07/2012 : https://gallery.technet.microsoft.com/office/MessageTrackingLog-search-72a5dbc7
# 2.0 - 12/19/2015 : Nicolas PRIGENT - www.get-cmd.com
# New features : search by subject / send results by email / export results in csv file
# Existing feature corrected : search by event ID did not work. Global variable was not created.
# Code optimized
# 
# Description: 
# This script searches the MessageTrackingLog in your Organization.
# You have to enter valid From Addr or To Addr or the subject and select the date. 
# You can also select a specific event ID. You can leave the blank entry to search the whole TrackingLog.
# 
###############################################################################################################

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$formTrackLog = New-Object System.Windows.Forms.Form
$labEventID = New-Object System.Windows.Forms.Label
$comboBoxEventID = New-Object System.Windows.Forms.ComboBox
$labEndDate = New-Object System.Windows.Forms.Label
$labStartDate = New-Object System.Windows.Forms.Label
$labFrom = New-Object System.Windows.Forms.Label
$dgResults = New-Object System.Windows.Forms.DataGrid
$dateTimePickerEnd = New-Object System.Windows.Forms.DateTimePicker
$dateTimePickerStart = New-Object System.Windows.Forms.DateTimePicker
$txtBoxRecipients = New-Object System.Windows.Forms.TextBox
$txtBoxSenders = New-Object System.Windows.Forms.TextBox
$buttonGo = New-Object System.Windows.Forms.Button
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
$labTo = New-Object System.Windows.Forms.Label
$labSubject = New-Object System.Windows.Forms.Label
$txtBoxSubject = New-Object System.Windows.Forms.TextBox
$txtBoxMail = New-Object System.Windows.Forms.TextBox
$txtBoxCSV = New-Object System.Windows.Forms.TextBox
$chkBoxCSV = New-Object System.Windows.Forms.CheckBox
$chkBoxMail = New-Object System.Windows.Forms.CheckBox
$txtBoxFromMail = New-Object System.Windows.Forms.TextBox
$txtBoxToMail = New-Object System.Windows.Forms.TextBox
$txtBoxCSV = New-Object System.Windows.Forms.TextBox
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------

Add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

$processData= 
{
	#This section determine the date and puts it in a working format
	$array = New-Object System.Collections.ArrayList
	$date1 = get-Date -date $dateTimePickerStart.value -uformat "%m/%d/%Y 00:00:01"
	$date3 = [System.DateTime]$date1
	$date2 = get-Date -date $dateTimePickerEnd.value -uformat "%m/%d/%Y 23:59:59"  
	$date4 = [System.DateTime]$date2
	$Sort = "TimeStamp"

	if ($ChoiceEventID -eq "BADMAIL" -or $ChoiceEventID -eq "DEFER" -or $ChoiceEventID -eq "DELIVER" -or $ChoiceEventID -eq "SEND" -or $ChoiceEventID -eq "DSN" -or $ChoiceEventID -eq "FAIL" -or $ChoiceEventID -eq "POISONMESSAGE" -or $ChoiceEventID -eq "RECEIVE" -or $ChoiceEventID -eq "REDIRECT" -or $ChoiceEventID -eq "RESOLVE" -or $ChoiceEventID -eq "SUBMIT" -or $ChoiceEventID -eq "TRANSFER" -or $ChoiceEventID -eq "EXPAND")
		{
			$EventID = $ChoiceEventID
		}
	else
		{
			$EventID = ""
		}
	
	if ( $EventID -ne "")
	{	
		if(($txtBoxRecipients.text -eq "") -and ($txtBoxSenders.text -eq "") -and ($txtBoxSubject.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -start $date3 -end $date4 -EventID $EventID -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
		elseif (($txtBoxRecipients.text -eq "") -and ($txtBoxSenders.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -MessageSubject $txtBoxSubject.text -EventID $EventID -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
        }
        elseif (($txtBoxSubject.text -eq "") -and ($txtBoxSenders.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -Recipients $txtBoxRecipients.text -EventID $EventID -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
        elseif (($txtBoxSubject.text -eq "") -and ($txtBoxRecipients.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -Sender $txtBoxSenders.text -EventID $EventID -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
        elseif ($txtBoxRecipients.text -eq "")
		{
			$ausgabe = Get-MessageTrackingLog -Sender $txtBoxSenders.text -MessageSubject $txtBoxSubject.text -EventID $EventID -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
		elseif ($txtBoxSenders.text -eq "")
		{
			$ausgabe = Get-MessageTrackingLog -Recipients $txtBoxRecipients.text -MessageSubject $txtBoxSubject.text -EventID $EventID -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
        elseif ($txtBoxSubject.text -eq "")
		{
			$ausgabe = Get-MessageTrackingLog -Recipients $txtBoxRecipients.text -sender $txtBoxSenders.text -EventID $EventID -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
        }
	}
	else
	{	
		if(($txtBoxRecipients.text -eq "") -and ($txtBoxSenders.text -eq "") -and ($txtBoxSubject.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
		elseif (($txtBoxRecipients.text -eq "") -and ($txtBoxSenders.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -MessageSubject $txtBoxSubject.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
        elseif (($txtBoxSubject.text -eq "") -and ($txtBoxSenders.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -Recipients $txtBoxRecipients.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject,EventID,  serverhostname | sort $sort
		}
        elseif (($txtBoxSubject.text -eq "") -and ($txtBoxRecipients.text -eq ""))
		{
			$ausgabe = Get-MessageTrackingLog -Sender $txtBoxSenders.text  -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
        elseif ($txtBoxRecipients.text -eq "")
		{
			$ausgabe = Get-MessageTrackingLog -Sender $txtBoxSenders.text -MessageSubject $txtBoxSubject.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
		elseif ($txtBoxSenders.text -eq "")
		{
			$ausgabe = Get-MessageTrackingLog -Recipients $txtBoxRecipients.text -MessageSubject $txtBoxSubject.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
		}
        elseif ($txtBoxSubject.text -eq "")
		{
			$ausgabe = Get-MessageTrackingLog -Recipients $txtBoxRecipients.text -sender $txtBoxSenders.text -start $date3 -end $date4 -resultsize unlimited | Select-object Timestamp, sender, @{Name='Recipients';Expression={[string]::join(";", ($_.Recipients))}}, messagesubject, EventID, serverhostname | sort $sort
        }
	}

    if ($ausgabe) {
	$array.addrange($ausgabe)
	$dgResults.datasource = $array
    $array | export-csv "MessageTrackingGUI.log"
        if ($chkBoxCSV.Checked) 
            {
                $array | export-csv $txtBoxCSV.text
            }
        if ($chkBoxMail.Checked) 
            {
                $Date = Get-Date
                $SubjectDate = "Exchange Message Tracking " + $Date.Tostring('HH:mm-MM.dd.yyyy') 
                send-mailmessage -to $txtBoxToMail.text -from $txtBoxFromMail.text -subject $SubjectDate -body "Attached is the message tracking" -Attachments 'MessageTrackingGUI.log' -BodyAsHTML -SmtpServer $txtBoxMail.text
            }
    $formTrackLog.refresh()
    } else {
    write-host "No results found!" -ForegroundColor white -BackgroundColor Red
    }
}


$handler_comboBoxEventID_SelectedIndexChanged= 
{
# Get the Event ID when item is selected
	$Global:ChoiceEventID = $comboBoxEventID.selectedItem.ToString()
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$formTrackLog.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 550
$System_Drawing_Size.Width = 1000
$formTrackLog.ClientSize = $System_Drawing_Size
$formTrackLog.DataBindings.DefaultDataSourceUpdateMode = 0
$formTrackLog.ForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)
$formTrackLog.Name = "formTrackLog"
$formTrackLog.Text = "Message Tracking Log GUI - By Nicolas PRIGENT [www.get-cmd.com]"
$formTrackLog.add_Load($handler_formTrackLog_Load)

$labEventID.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 570
$System_Drawing_Point.Y = 5
$labEventID.Location = $System_Drawing_Point
$labEventID.Name = "labEventID"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 60
$labEventID.Size = $System_Drawing_Size
$labEventID.TabIndex = 18
$labEventID.Text = "Event ID:"
$labEventID.add_Click($handler_labEventID_Click)

$formTrackLog.Controls.Add($labEventID)

$comboBoxEventID.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxEventID.FormattingEnabled = $True
$comboBoxEventID.Items.Add("")|Out-Null
$comboBoxEventID.Items.Add("SEND")|Out-Null
$comboBoxEventID.Items.Add("DELIVER")|Out-Null
$comboBoxEventID.Items.Add("RECEIVE")|Out-Null
$comboBoxEventID.Items.Add("FAIL")|Out-Null
$comboBoxEventID.Items.Add("DSN")|Out-Null
$comboBoxEventID.Items.Add("RESOLVE")|Out-Null
$comboBoxEventID.Items.Add("EXPAND")|Out-Null
$comboBoxEventID.Items.Add("REDIRECT")|Out-Null
$comboBoxEventID.Items.Add("TRANSFER")|Out-Null
$comboBoxEventID.Items.Add("SUBMIT")|Out-Null
$comboBoxEventID.Items.Add("POISONMESSAGE")|Out-Null
$comboBoxEventID.Items.Add("DEFER")|Out-Null
$System_Drawing_PointComboEVentID = New-Object System.Drawing.Point
$System_Drawing_PointComboEVentID.X = 630
$System_Drawing_PointComboEVentID.Y = 3
$comboBoxEventID.Location = $System_Drawing_PointComboEVentID
$comboBoxEventID.Name = "comboBoxEventID"
$System_Drawing_SizeComboEVentID = New-Object System.Drawing.Size
$System_Drawing_SizeComboEVentID.Height = 21
$System_Drawing_SizeComboEVentID.Width = 121
$comboBoxEventID.Size = $System_Drawing_SizeComboEVentID
$comboBoxEventID.TabIndex = 17
$comboBoxEventID.add_SelectedIndexChanged($handler_comboBoxEventID_SelectedIndexChanged)
$formTrackLog.Controls.Add($comboBoxEventID)

$labEndDate.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 300
$System_Drawing_Point.Y = 33
$labEndDate.Location = $System_Drawing_Point
$labEndDate.Name = "labEndDate"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 54
$labEndDate.Size = $System_Drawing_Size
$labEndDate.TabIndex = 12
$labEndDate.Text = "End"

$formTrackLog.Controls.Add($labEndDate)

$labStartDate.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 300
$System_Drawing_Point.Y = 5
$labStartDate.Location = $System_Drawing_Point
$labStartDate.Name = "labStartDate"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 54
$labStartDate.Size = $System_Drawing_Size
$labStartDate.TabIndex = 11
$labStartDate.Text = "Start"
$labStartDate.add_Click($handler_labStartDate_Click)

$formTrackLog.Controls.Add($labStartDate)

$dgResults.AllowSorting = $true
$dgResults.Anchor = 15
$dgResults.DataBindings.DefaultDataSourceUpdateMode = 0
$dgResults.DataMember = ""
$dgResults.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 9
$System_Drawing_Point.Y = 108
$dgResults.Location = $System_Drawing_Point
$dgResults.Name = "dgResults"
$dgResults.PreferredColumnWidth = 200
$dgResults.ReadOnly = $True
$dgResults.RowHeadersVisible = $false
$dgResults.RowHeaderWidth = 60
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 500
$System_Drawing_Size.Width = 990
$dgResults.Size = $System_Drawing_Size
$dgResults.TabIndex = 9
$dgResults.add_Navigate($handler_dgResults_Navigate)

$formTrackLog.Controls.Add($dgResults)

$dateTimePickerEnd.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 360
$System_Drawing_Point.Y = 33
$dateTimePickerEnd.Location = $System_Drawing_Point
$dateTimePickerEnd.Name = "dateTimePicker2"
$System_Drawing_SizeEnd = New-Object System.Drawing.Size
$System_Drawing_SizeEnd.Height = 20
$System_Drawing_SizeEnd.Width = 200
$dateTimePickerEnd.Size = $System_Drawing_SizeEnd
$dateTimePickerEnd.TabIndex = 8

$formTrackLog.Controls.Add($dateTimePickerEnd)

$dateTimePickerStart.CustomFormat = "MM/DD/YYYY 00:00:01"
$dateTimePickerStart.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 360
$System_Drawing_Point.Y = 3
$dateTimePickerStart.Location = $System_Drawing_Point
$dateTimePickerStart.Name = "dateTimePicker1"
$System_Drawing_SizeStart = New-Object System.Drawing.Size
$System_Drawing_SizeStart.Height = 20
$System_Drawing_SizeStart.Width = 200
$dateTimePickerStart.Size = $System_Drawing_SizeStart
$dateTimePickerStart.TabIndex = 7

$formTrackLog.Controls.Add($dateTimePickerStart)

$txtBoxRecipients.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 40
$System_Drawing_Point.Y = 30
$txtBoxRecipients.Location = $System_Drawing_Point
$txtBoxRecipients.Name = "txtBoxRecipients"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 250
$txtBoxRecipients.Size = $System_Drawing_Size
$txtBoxRecipients.TabIndex = 4
$txtBoxRecipients.Text = ""
$formTrackLog.Controls.Add($txtBoxRecipients)

$txtBoxSubject.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 65
$System_Drawing_Point.Y = 65
$txtBoxSubject.Location = $System_Drawing_Point
$txtBoxSubject.Name = "txtBoxSubject"
$System_Drawing_SizeSubject = New-Object System.Drawing.Size
$System_Drawing_SizeSubject.Height = 20
$System_Drawing_SizeSubject.Width = 495
$txtBoxSubject.Size = $System_Drawing_SizeSubject
$txtBoxSubject.TabIndex = 4
$txtBoxSubject.Text = ""
$formTrackLog.Controls.Add($txtBoxSubject)

$txtBoxSenders.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 40
$System_Drawing_Point.Y = 3
$txtBoxSenders.Location = $System_Drawing_Point
$txtBoxSenders.Name = "txtBoxSenders"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 250
$txtBoxSenders.Size = $System_Drawing_Size
$txtBoxSenders.TabIndex = 3
$txtBoxSenders.Text = ""
$formTrackLog.Controls.Add($txtBoxSenders)

$buttonGo.DataBindings.DefaultDataSourceUpdateMode = 0
$buttonGo.ForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 755
$System_Drawing_Point.Y = 3
$buttonGo.Location = $System_Drawing_Point
$buttonGo.Name = "button1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 25
$System_Drawing_Size.Width = 240
$buttonGo.Size = $System_Drawing_Size
$buttonGo.TabIndex = 1
$buttonGo.Text = ">>> Run <<<"
$buttonGo.UseVisualStyleBackColor = $True
$buttonGo.add_Click($processData)

$formTrackLog.Controls.Add($buttonGo)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 3
$System_Drawing_Point.Y = 5
$labFrom.Location = $System_Drawing_Point
$labFrom.Name = "labFrom"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 54
$labFrom.Size = $System_Drawing_Size
$labFrom.TabIndex = 11
$labFrom.Text = "From:"

$formTrackLog.Controls.Add($labFrom)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 3
$System_Drawing_Point.Y = 32
$labTo.Location = $System_Drawing_Point
$labTo.Name = "labTo"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 54
$labTo.Size = $System_Drawing_Size
$labTo.TabIndex = 11
$labTo.Text = "To:"
$formTrackLog.Controls.Add($labTo)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 3
$System_Drawing_Point.Y = 67
$labSubject.Location = $System_Drawing_Point
$labSubject.Name = "labSubject"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 54
$labSubject.Size = $System_Drawing_Size
$labSubject.TabIndex = 11
$labSubject.Text = "Subject:"
$formTrackLog.Controls.Add($labSubject)

$System_Drawing_SizeCSV = New-Object System.Drawing.Size
$System_Drawing_SizeCSV.Width = 84
$System_Drawing_SizeCSV.Height = 24
$chkBoxCSV.Size = $System_Drawing_SizeCSV
$chkBoxCSV.TabIndex = 1
$chkBoxCSV.Text = "Export CSV"
$System_Drawing_PointCSV = New-Object System.Drawing.Point
$System_Drawing_PointCSV.X = 570
$System_Drawing_PointCSV.Y = 64
$chkBoxCSV.Location = $System_Drawing_PointCSV
$chkBoxCSV.DataBindings.DefaultDataSourceUpdateMode = 0
$chkBoxCSV.Name = "chkBoxCSV"
$formTrackLog.Controls.Add($chkBoxCSV)

$System_Drawing_SizeMail = New-Object System.Drawing.Size
$System_Drawing_SizeMail.Width = 90
$System_Drawing_SizeMail.Height = 24
$chkBoxMail.Size = $System_Drawing_SizeMail
$chkBoxMail.TabIndex = 1
$chkBoxMail.Text = "Send by mail"
$System_Drawing_PointMail = New-Object System.Drawing.Point
$System_Drawing_PointMail.X = 570
$System_Drawing_PointMail.Y = 34
$chkBoxMail.Location = $System_Drawing_PointMail
$chkBoxMail.DataBindings.DefaultDataSourceUpdateMode = 0
$chkBoxMail.Name = "chkBoxMail"
$formTrackLog.Controls.Add($chkBoxMail)

$txtBoxMail.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_PointMail = New-Object System.Drawing.Point
$System_Drawing_PointMail.X = 660
$System_Drawing_PointMail.Y = 34
$txtBoxMail.Location = $System_Drawing_PointMail
$txtBoxMail.Name = "txtBoxMail"
$System_Drawing_SizeMail = New-Object System.Drawing.Size
$System_Drawing_SizeMail.Height = 20
$System_Drawing_SizeMail.Width = 110
$txtBoxMail.Size = $System_Drawing_SizeMail
$txtBoxMail.TabIndex = 3
$txtBoxMail.Text = "SMTP Server"
$formTrackLog.Controls.Add($txtBoxMail)

$txtBoxFromMail.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_PointFromMail = New-Object System.Drawing.Point
$System_Drawing_PointFromMail.X = 775
$System_Drawing_PointFromMail.Y = 34
$txtBoxFromMail.Location = $System_Drawing_PointFromMail
$txtBoxFromMail.Name = "txtBoxFromMail"
$System_Drawing_SizeFromMail = New-Object System.Drawing.Size
$System_Drawing_SizeFromMail.Height = 20
$System_Drawing_SizeFromMail.Width = 110
$txtBoxFromMail.Size = $System_Drawing_SizeFromMail
$txtBoxFromMail.TabIndex = 3
$txtBoxFromMail.Text = "From"
$formTrackLog.Controls.Add($txtBoxFromMail)

$txtBoxToMail.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_PointToMail = New-Object System.Drawing.Point
$System_Drawing_PointToMail.X = 890
$System_Drawing_PointToMail.Y = 34
$txtBoxToMail.Location = $System_Drawing_PointToMail
$txtBoxToMail.Name = "txtBoxToMail"
$System_Drawing_SizeToMail = New-Object System.Drawing.Size
$System_Drawing_SizeToMail.Height = 20
$System_Drawing_SizeToMail.Width = 110
$txtBoxToMail.Size = $System_Drawing_SizeToMail
$txtBoxToMail.TabIndex = 3
$txtBoxToMail.Text = "To"
$formTrackLog.Controls.Add($txtBoxToMail)

$txtBoxCSV.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_PointTXTCSV = New-Object System.Drawing.Point
$System_Drawing_PointTXTCSV.X = 660
$System_Drawing_PointTXTCSV.Y = 65
$txtBoxCSV.Location = $System_Drawing_PointTXTCSV
$txtBoxCSV.Name = "txtBoxCSV"
$System_Drawing_SizeTXTCSV = New-Object System.Drawing.Size
$System_Drawing_SizeTXTCSV.Height = 20
$System_Drawing_SizeTXTCSV.Width = 250
$txtBoxCSV.Size = $System_Drawing_SizeTXTCSV
$txtBoxCSV.TabIndex = 3
$txtBoxCSV.Text = "Path to csv file"
$formTrackLog.Controls.Add($txtBoxCSV)


#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $formTrackLog.WindowState
#Init the OnLoad event to correct the initial state of the form
$formTrackLog.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$formTrackLog.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm
