{
  applications = {
    systemSettings = {
      battery = {
        options = {
          preventAutomaticSleepingOnPowerAdapterWhenTheDisplayIsOff = false;
        };
      };
      general = {
        dateAndTime = {
          setTimeZoneAutomaticallyUsingYourCurrentLocation = true;
        };
        sharing = {
          contentCaching = false;
          fileSharing = false;
          fileSharingOptions = {
            sharedFolders = {
              "/Users/pbear/Public" = "Dossier public de Bertrand Crevin";
            };
          };
          printerSharing = false;
          remoteApplicationScripting = false;
          remoteApplicationScriptingOptions = {
            allowAccessFor = "Only these users";
          };
          remoteManagement = false;
          screenSharing = false;
          screenSharingOptions = {
            allowAccessFor = "Only these users";
          };
        };
        softwareUpdate = {
          automaticallyDownloadNewUpdatesWhenAvailable = true;
          automaticallyInstallApplicationUpdatesFromTheAppStore = true;
          automaticallyInstallMacOSUpdates = true;
          automaticallyInstallSystemDataFilesAndSecurityUpdates = true;
        };
      };
      lockScreen = {
        turnDisplayOffOnPowerAdapterWhenInactive = "For 20 minutes";
      };
      network = {
        firewall = {
          firewall = false;
          options = {
            automaticallyAllowBuiltInSoftwareToReceiveIncomingConnections = true;
            automaticallyAllowDownloadedSignedSoftwareToReceiveIncomingConnections = true;
            blockAllIncomingConnections = false;
            enableStealthMode = false;
          };
        };
      };
      privacyAndSecurity = {
        analyticsAndImprovements = {
          shareMacAnalytics = false;
          shareWithAppDevelopers = false;
        };
      };
    };
  };
}
