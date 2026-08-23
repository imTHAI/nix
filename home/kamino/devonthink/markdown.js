/* Callouts Obsidian pour la prévisualisation Markdown de DEVONthink.
   Source Nix : home/kamino/devonthink/markdown.js
   Désigné dans Réglages ▸ Files ▸ Markdown ▸ JavaScript.

   « > [!warning] Titre » n'est pas du Markdown : c'est une extension
   d'Obsidian qu'aucun moteur de DT n'implémente, donc le marqueur reste
   visible en texte brut. Ce script réécrit après coup les blockquotes
   concernés en <div class="callout">, que markdown.css habille.

   Dépendance de rendu : le titre ne peut être séparé du corps que si le
   moteur a produit un <br> à la fin de la première ligne — donc si
   « Force line breaks » est coché. Sans lui, tout le bloc tombe dans le
   corps et le titre se réduit au nom du type ; c'est dégradé mais lisible. */

(function () {
  "use strict";

  var ICONS = {
    note: "📝", info: "ℹ️", tip: "💡", hint: "💡",
    important: "❗", warning: "⚠️", caution: "⚠️", attention: "⚠️",
    danger: "🛑", error: "🛑", bug: "🐞", failure: "❌",
    success: "✅", done: "✅", check: "✅",
    question: "❓", faq: "❓", help: "❓",
    quote: "❝", cite: "❝", abstract: "📄", summary: "📄",
    example: "🧪", todo: "☑️"
  };

  var LABELS = {
    note: "Note", info: "Info", tip: "Astuce", hint: "Astuce",
    important: "Important", warning: "Attention", caution: "Prudence",
    attention: "Attention", danger: "Danger", error: "Erreur", bug: "Bug",
    failure: "Échec", success: "Succès", done: "Fait", check: "Vérifié",
    question: "Question", faq: "FAQ", help: "Aide", quote: "Citation",
    cite: "Citation", abstract: "Résumé", summary: "Résumé",
    example: "Exemple", todo: "À faire"
  };

  // [!type] éventuellement suivi de + ou - (repli/dépli Obsidian, ignoré ici)
  // puis d'un titre libre jusqu'au premier <br> ou à la fin du paragraphe.
  var MARKER = /^\s*\[!([A-Za-z]+)\]([+-])?\s*/;

  function transform(bq) {
    var firstP = bq.querySelector("p");
    if (!firstP) return;

    var m = MARKER.exec(firstP.innerHTML);
    if (!m) return;

    var type = m[1].toLowerCase();
    var rest = firstP.innerHTML.slice(m[0].length);

    // Le titre s'arrête au premier saut de ligne dur ; au-delà, c'est le corps.
    var brk = rest.search(/<br\s*\/?>/i);
    var title, inlineBody = "";
    if (brk >= 0) {
      title = rest.slice(0, brk);
      inlineBody = rest.slice(brk).replace(/^<br\s*\/?>/i, "");
    } else {
      title = rest;
    }

    // Un titre trop long est en réalité du corps aspiré faute de <br>.
    if (!brk && title.replace(/<[^>]+>/g, "").length > 90) {
      inlineBody = title;
      title = "";
    }

    var callout = document.createElement("div");
    callout.className = "callout";
    callout.setAttribute("data-callout", type);

    var head = document.createElement("div");
    head.className = "callout-title";
    head.innerHTML =
      '<span class="callout-icon">' + (ICONS[type] || "📌") + "</span>" +
      "<span>" + (title.trim() || LABELS[type] || m[1]) + "</span>";

    var body = document.createElement("div");
    body.className = "callout-body";

    if (inlineBody.trim()) {
      var p = document.createElement("p");
      p.innerHTML = inlineBody;
      body.appendChild(p);
    }
    // Les blocs suivants du blockquote (paragraphes, listes, tableaux) suivent
    // tels quels : on déplace les nœuds plutôt que de recopier de l'innerHTML,
    // ce qui préserverait mal les liens x-devonthink-item.
    var nodes = Array.prototype.slice.call(bq.childNodes);
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i] === firstP) continue;
      body.appendChild(nodes[i]);
    }

    callout.appendChild(head);
    callout.appendChild(body);
    bq.parentNode.replaceChild(callout, bq);
  }

  function run() {
    var quotes = document.querySelectorAll("blockquote");
    for (var i = 0; i < quotes.length; i++) {
      // Un callout imbriqué serait déjà traité par son parent.
      if (!quotes[i].parentNode) continue;
      transform(quotes[i]);
    }
  }

  // DEVONthink peut injecter le script avant ou après le corps de la page.
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
