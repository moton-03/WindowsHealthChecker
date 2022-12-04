#region Images

#endregion

$ToolStripMenuItem_sfc_scannow.add_Click({param($sender, $e)
    [System.Windows.Forms.MessageBox]::Show("This tool is currently under development.");
})

$ToolStripMenuItem_About.add_Click({param($sender, $e)
    [System.Windows.Forms.MessageBox]::Show("Windows Health Checker", "About");
})

$ToolStripMenuItem_mrt.add_Click({param($sender, $e)
    Start-Process -FilePath "mrt.exe"
    
    $Text.Text = "%windir%\debug\mrt.log"

})

