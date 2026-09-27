{
  applications = {
    finder = {
      menuBar = {
        view = {
          showPathBar = true;
          showSidebar = true;
          showStatusBar = true;
        };
      };
      settings = {
        advanced = {
          keepFoldersOnTop = {
            inWindowsWhenSortingByName = true;
          };
          removeItemsFromTheTrashAfter30Days = true;
          showAllFilenameExtensions = false;
          showWarningBeforeChangingAnExtension = false;
          whenPerformingASearch = "Search the Current Folder";
        };
        general = {
          showTheseItemsOnTheDesktop = {
            cdsDvdsAndiPods = true;
            externalDisks = true;
            hardDisks = false;
          };
        };
        sidebar = {
          recentTags = false;
        };
      };
    };
    systemSettings = {
      accessibility = {
        audio = {
          backgroundSoundsOptions = {
            timer = false;
          };
        };
        hoverText = {
          hoverTypingOptions = {
            textFont = "Default";
          };
          options = {
            textFont = "Default";
          };
        };
        liveCaptions = {
          fontFamily = "Default";
        };
        pointerControl = {
          trackpadOptions = {
            dragging = "Off";
            useTrackpadForScrolling = true;
          };
        };
        readAndSpeak = {
          typingFeedback = {
            characters = true;
            modifierKeys = false;
            selectionChanges = false;
            words = true;
          };
        };
        subtitlesAndCaptioning = {
          applyAcrossApps = true;
        };
      };
      desktopAndDock = {
        dock = {
          animateOpeningApplications = false;
          automaticallyHideAndShowTheDock = {
            delay = 0.0;
            duration = 0.0;
            enabled = true;
          };
          minimizeWindowsIntoApplicationIcon = true;
          minimizedWindowAnimation = "Scale Effect";
          showSuggestedAndRecentAppsInDock = false;
        };
        missionControl = {
          automaticallyRearrangeSpacesBasedOnMostRecentUse = false;
          shortcuts = {
            showDesktop = "F11";
          };
        };
      };
      general = {
        autoFillAndPasswords = {
          deleteVerificationCodesAfterUse = true;
        };
        languageAndRegion = {
          applications = { };
          preferredLanguages = [
            "fr-FR"
            "en-US"
          ];
          region = "fr_FR";
        };
        sharing = {
          mediaSharing = {
            shareMediaWithGuests = false;
          };
        };
      };
      keyboard = {
        delayUntilRepeat = 25;
        keyRepeatRate = 6;
        keyboardShortcuts = {
          accessibility = {
            decreaseContrast = false;
            increaseContrast = false;
            invertColors = false;
            showAccessibilityControls = "⌥⌘F5";
            turnVoiceOverOnOrOff = "⌘F5";
          };
          appShortcuts = {
            menuItems = { };
            showHelpMenu = "⇧⌘/";
          };
          display = {
            decreaseDisplayBrightness = "F14";
            increaseDisplayBrightness = "F15";
          };
          inputSources = {
            selectNextSourceInInputMenu = "⌃⌥Space";
            selectThePreviousInputSource = "⌃Space";
          };
          keyboard = {
            changeTheWayTabMovesFocus = "⌃F7";
            moveFocusToActiveOrNextWindow = "⌃F4";
            moveFocusToNextWindow = "⌘`";
            moveFocusToStatusMenus = "⌃F8";
            moveFocusToTheDock = "⌃F3";
            moveFocusToTheFloatingWindow = "⌃F6";
            moveFocusToTheMenuBar = "⌃F2";
            moveFocusToTheWindowToolbar = "⌃F5";
            turnKeyboardAccessOnOrOff = "⌃F1";
          };
          launchpadAndDock = {
            turnDockHidingOnOff = "⌥⌘D";
          };
          missionControl = {
            moveLeftASpace = "⌃←";
            moveRightASpace = "⌃→";
            showNotificationCenter = false;
            switchToDesktop1 = false;
          };
          screenshots = {
            copyPictureOfScreenToTheClipboard = "⌃⇧⌘3";
            copyPictureOfSelectedAreaToTheClipboard = "⌃⇧⌘4";
            savePictureOfScreenAsAFile = "⇧⌘3";
            savePictureOfSelectedAreaAsAFile = "⇧⌘4";
          };
          spotlight = {
            showApps = false;
            showFinderSearchWindow = "⌥⌘Space";
            showSpotlightSearch = "⌘Space";
          };
        };
        textInput = {
          inputSources = [
            "com.apple.keylayout.US"
            "com.apple.keylayout.ABC"
          ];
          useSmartQuotesAndDashes = false;
        };
      };
      menuBar = {
        clock = {
          showAmPm = true;
          showTheDayOfTheWeek = true;
        };
        timeMachine = true;
      };
      notifications = {
        notificationCenter = {
          summarizeNotifications = true;
        };
      };
      privacyAndSecurity = {
        appleAdvertising = {
          personalizedAds = false;
        };
      };
      spotlight = {
        searchResults = {
          appStore = true;
          apps = true;
          books = true;
          calculator = true;
          calendar = true;
          contacts = true;
          dictionary = true;
          files = true;
          folders = true;
          games = true;
          iPhoneApps = true;
          mail = true;
          menuItems = true;
          messages = true;
          music = true;
          notes = true;
          phone = true;
          photos = true;
          podcasts = true;
          reminders = true;
          safari = true;
          shortcuts = true;
          systemSettings = true;
          tips = true;
          voiceMemos = true;
        };
      };
      trackpad = {
        pointAndClick = {
          click = "Medium";
          tapToClick = true;
        };
        scrollAndZoom = {
          rotate = true;
          zoomInOrOut = true;
        };
      };
    };
  };
}
