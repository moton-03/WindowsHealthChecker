    #region Environment Setup

    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing


    } catch {Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during Environment Setup."}

    #endregion Environment Setup
