{ pkgs, ... }: {
  # Managed storage pour Bitwarden — pointe vers le vault self-hosted
  # https://bitwarden.com/help/managed-storage-policies/
  home.file."Library/Application Support/Mozilla/ManagedStorage/{446900e4-71c2-419f-a6a7-df9c091e268b}.json".text = builtins.toJSON {
    name        = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
    description = "Bitwarden managed storage";
    type        = "storage.managed";
    data = {
      environment = {
        base = "https://vault.example.com";
      };
    };
  };

  programs.firefox = {
    enable = true;
    # Firefox installé par homebrew cask — home-manager gère uniquement le profil
    package = null;

    profiles.default = {
      id = 0;
      isDefault = true;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        sponsorblock
        # AdGuard Assistant : injecté automatiquement par l'app AdGuard desktop
      ];

      search = {
        force   = true;
        default = "google";
        privateDefault = "google";
      };

      settings = {
        # ── Télémétrie & rapports ──────────────────────────────
        "datareporting.healthreport.uploadEnabled"      = false;
        "datareporting.policy.dataSubmissionEnabled"    = false;
        "toolkit.telemetry.enabled"                     = false;
        "toolkit.telemetry.unified"                     = false;
        "toolkit.telemetry.archive.enabled"             = false;
        "toolkit.telemetry.reportingpolicy.firstRun"    = false;
        "toolkit.telemetry.bhrPing.enabled"             = false;
        "toolkit.telemetry.firstShutdownPing.enabled"   = false;
        "toolkit.telemetry.newProfilePing.enabled"      = false;
        "toolkit.telemetry.shutdownPingSender.enabled"  = false;
        "toolkit.telemetry.updatePing.enabled"          = false;
        "app.shield.optoutstudies.enabled"              = false;
        "app.normandy.enabled"                          = false;

        # ── Mode strict (Enhanced Tracking Protection) ─────────
        "browser.contentblocking.category"                       = "strict";
        "privacy.trackingprotection.enabled"                     = true;
        "privacy.trackingprotection.socialtracking.enabled"      = true;
        "privacy.trackingprotection.cryptomining.enabled"        = true;
        "privacy.trackingprotection.fingerprinting.enabled"      = true;
        "network.cookie.cookieBehavior"                          = 5;

        # ── Fingerprinting resistance ──────────────────────────
        "privacy.resistFingerprinting"                  = true;
        "privacy.fingerprintingProtection"              = true;

        # ── Pocket / contenus sponsorisés ──────────────────────
        "extensions.pocket.enabled"                                       = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories"     = false;
        "browser.newtabpage.activity-stream.showSponsored"                = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites"        = false;
        "browser.newtabpage.activity-stream.feeds.topsites"               = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;

        # ── Onglets verticaux à gauche (Firefox 138+) ──────────
        "sidebar.revamp"        = true;
        "sidebar.verticalTabs"  = true;

        # ── Gestionnaire de mots de passe désactivé (Bitwarden gère) ──
        "signon.rememberSignons"                                     = false;
        "signon.autofillForms"                                       = false;
        "signon.generation.enabled"                                  = false;
        "signon.management.page.breach-alerts.enabled"               = false;
        "extensions.formautofill.addresses.enabled"                  = false;
        "extensions.formautofill.creditCards.enabled"                = false;
        "extensions.formautofill.heuristics.enabled"                 = false;

        # ── Divers ─────────────────────────────────────────────
        "browser.aboutConfig.showWarning"               = false;  # plus de warning about:config
        "browser.startup.page"                           = 3;       # restaure la session précédente (onglets épinglés persistent)
        "browser.startup.homepage"                       = "about:home";
      };
    };
  };
}
