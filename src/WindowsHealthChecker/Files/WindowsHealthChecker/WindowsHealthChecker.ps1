<#
    .NOTES
    ===========================================================================
        FileName:  WindowsHealthChecker.ps1
        Author:  kira_
        Created On:  2022/12/04
        Last Updated:  2022/12/04
        Organization:
        Version:      v0.1
    ===========================================================================

    .DESCRIPTION

    .DEPENDENCIES
#>

# ScriptBlock to Execute in STA Runspace
$sbGUI = {
    param($BaseDir)
Add-Type @"
using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Runtime.InteropServices;
public class psd {
public static void SetCompat()
{
//	SetProcessDPIAware();
Application.EnableVisualStyles();
Application.SetCompatibleTextRenderingDefault(false);
}
[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool SetProcessDPIAware();
}
"@  -ReferencedAssemblies System.Windows.Forms,System.Drawing,System.Drawing.Primitives,System.Net.Primitives,System.ComponentModel.Primitives,Microsoft.Win32.Primitives
$script:tscale = 1

    #region Dot Sourcing of files

    $dotSourceDir = $BaseDir

    . "$($dotSourceDir)\Functions.ps1"
    . "$($dotSourceDir)\EnvSetup.ps1"

    #endregion Dot Sourcing of files

    #region Form Initialization

    try {
        ConvertFrom-WinFormsXML -Reference refs -Suppress -Xml @"
  <Form Name="MainForm" Size="534,400" Tag="VisualStyle,DPIAware" Text="WindowsHealthChecker">
    <MenuStrip Name="ToolStrip" ImageScalingSize="16,16" Text="ToolStrip">
      <ToolStripMenuItem Name="ToolStripMenuItem_Check" Text="Check">
        <ToolStripMenuItem Name="ToolStripMenuItem_sfc_scannow" Text="Scan system file integrity" />
        <ToolStripMenuItem Name="ToolStripMenuItem_mrt" Text="Launch the Malicious Software Removal Tool" />
      </ToolStripMenuItem>
      <ToolStripMenuItem Name="ToolStripMenuItem_Help" Text="Help">
        <ToolStripMenuItem Name="ToolStripMenuItem_Wiki" Text="Wiki" />
        <ToolStripSeparator Name="ToolStripSeparator1" />
        <ToolStripMenuItem Name="ToolStripMenuItem_About" Text="About" />
      </ToolStripMenuItem>
    </MenuStrip>
    <StatusStrip Name="StatusStrip" ImageScalingSize="16,16" Text="StatusStrip" />
    <Panel Name="Panel" Dock="Fill">
      <RichTextBox Name="Text" Dock="Fill" WordWrap="False" />
    </Panel>
  </Form>
"@
    } catch {Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during Form Initialization."}

    #endregion Form Initialization


    . "$($dotSourceDir)\Events.ps1"
    #region Other Actions Before ShowDialog

    try {
        Remove-Variable -Name eventSB
    } catch {Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered before ShowDialog."}

    #endregion Other Actions Before ShowDialog

        # Show the form
    try {[void]$Script:refs['MainForm'].ShowDialog()} catch {Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered unexpectedly at ShowDialog."}

    <#
    #region Actions After Form Closed

    try {

    } catch {Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered after Form close."}

    #endregion Actions After Form Closed
    #>
}

#region Start Point of Execution

    # Initialize STA Runspace
$rsGUI = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
$rsGUI.ApartmentState = 'STA'
$rsGUI.ThreadOptions = 'ReuseThread'
$rsGUI.Open()

    # Create the PSCommand, Load into Runspace, and BeginInvoke
$cmdGUI = [Management.Automation.PowerShell]::Create().AddScript($sbGUI).AddParameter('BaseDir',$PSScriptRoot)
$cmdGUI.RunSpace = $rsGUI
$handleGUI = $cmdGUI.BeginInvoke()

    # Hide Console Window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)

    #Loop Until GUI Closure
while ( $handleGUI.IsCompleted -eq $false ) {Start-Sleep -Seconds 5}

    # Dispose of GUI Runspace/Command
$cmdGUI.EndInvoke($handleGUI)
$cmdGUI.Dispose()
$rsGUI.Dispose()

Exit

#endregion Start Point of Execution
