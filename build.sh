#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# build.sh — assembles all pages from components + content
# ============================================================
#
# Usage: bash build.sh
#
# Arguments to build_page:
#   $1  PAGE_TITLE
#   $2  PAGE_DESC
#   $3  CANONICAL
#   $4  OG_TITLE
#   $5  CONTENT_FILE
#   $6  ACTIVE_NAV   (href value to mark active, e.g. "/" or "/pages/about/")
#   $7  BASE         (relative path prefix: "" for root, "../../" for depth-2)
#   $8  CSS_EXTRA    (extra <link> tag for page-specific CSS, or "")
#   $9  EXTRA_HEAD   (JSON-LD or other <head> content, or "")
#   $10 OUT_FILE
# ============================================================

HEADER="components/header.html"
FOOTER="components/footer.html"
DOMAIN="https://falklands-south-georgia-antarctica-cruise.com"
TMP=$(mktemp -d)

cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

build_page() {
  local TITLE="$1"
  local DESC="$2"
  local CANONICAL="$3"
  local OG_TITLE="$4"
  local CONTENT="$5"
  local ACTIVE_NAV="$6"
  local BASE="$7"
  local CSS_EXTRA="$8"
  local EXTRA_HEAD="$9"
  local OUT="${10}"

  local TMP_HEADER="$TMP/header_$(basename "$OUT").html"
  local TMP_CONTENT="$TMP/content_$(basename "$OUT").html"
  local TMP_FOOTER="$TMP/footer_$(basename "$OUT").html"

  # ROOT href for nav home link
  local ROOT_HREF="${BASE}index.html"
  if [ -z "$BASE" ]; then
    ROOT_HREF="./"
  fi

  # Process header: active nav + relative paths
  # Use \(>\) to match only nav links (href="...">), not the logo (href="..." class=)
  sed \
    -e "s|href=\"${ACTIVE_NAV}\"\(>\)|href=\"${ACTIVE_NAV}\" class=\"active\"\1|g" \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|href=\"/pages/|href=\"${BASE}pages/|g" \
    -e "s|src=\"/images/|src=\"${BASE}images/|g" \
    -e "s|src=\"/js/|src=\"${BASE}js/|g" \
    -e "s|src=\"/css/|src=\"${BASE}css/|g" \
    "$HEADER" > "$TMP_HEADER"

  # Process footer: relative paths
  sed \
    -e "s|href=\"/pages/|href=\"${BASE}pages/|g" \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|src=\"/images/|src=\"${BASE}images/|g" \
    "$FOOTER" > "$TMP_FOOTER"

  # Process content: relative paths
  sed \
    -e "s|href=\"/pages/|href=\"${BASE}pages/|g" \
    -e "s|href=\"/\"|href=\"${ROOT_HREF}\"|g" \
    -e "s|src=\"/images/|src=\"${BASE}images/|g" \
    "$CONTENT" > "$TMP_CONTENT"

  # Ensure output directory exists
  local OUT_DIR
  OUT_DIR="$(dirname "$OUT")"
  mkdir -p "$OUT_DIR"

  # Build the page
  {
    echo '<!DOCTYPE html>'
    echo '<html lang="en">'
    echo '<head>'
    echo '  <meta charset="UTF-8">'
    echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0">'
    echo "  <title>${TITLE}</title>"
    echo "  <meta name=\"description\" content=\"${DESC}\">"
    echo "  <link rel=\"canonical\" href=\"${CANONICAL}\">"
    echo "  <meta property=\"og:type\" content=\"article\">"
    echo "  <meta property=\"og:title\" content=\"${OG_TITLE}\">"
    echo "  <meta property=\"og:description\" content=\"${DESC}\">"
    echo "  <meta property=\"og:url\" content=\"${CANONICAL}\">"
    echo "  <meta property=\"og:site_name\" content=\"Falklands South Georgia Antarctica Cruise Rankings\">"
    echo "  <meta name=\"twitter:card\" content=\"summary_large_image\">"
    echo "  <meta name=\"twitter:title\" content=\"${OG_TITLE}\">"
    echo "  <meta name=\"twitter:description\" content=\"${DESC}\">"
    echo "  <link rel=\"icon\" type=\"image/svg+xml\" href=\"${BASE}favicon.svg\">"
    echo "  <link rel=\"stylesheet\" href=\"${BASE}css/global.css\">"
    if [ -n "$CSS_EXTRA" ]; then
      echo "  $CSS_EXTRA"
    fi
    if [ -n "$EXTRA_HEAD" ]; then
      echo "$EXTRA_HEAD"
    fi
    echo '</head>'
    echo '<body>'
    cat "$TMP_HEADER"
    cat "$TMP_CONTENT"
    cat "$TMP_FOOTER"
    echo "  <script src=\"${BASE}js/nav.js\"></script>"
    echo '</body>'
    echo '</html>'
  } > "$OUT"

  echo "  Built: $OUT"
}

# ============================================================
# JSON-LD for index.html
# ============================================================

INDEX_JSONLD=$(cat <<'JSONLD'
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": "Best Falklands, South Georgia & Antarctica Cruises: Expert Rankings 2026",
    "description": "Independent editorial rankings of the 10 best expedition cruise operators for the Falklands, South Georgia and Antarctica route, scored on ship size, time ashore, expedition team expertise, and value.",
    "url": "https://falklands-south-georgia-antarctica-cruise.com/",
    "datePublished": "2026-01-01",
    "dateModified": "2026-05-04",
    "author": {
      "@type": "Organization",
      "name": "Falklands South Georgia Antarctica Cruise Rankings"
    },
    "publisher": {
      "@type": "Organization",
      "name": "Falklands South Georgia Antarctica Cruise Rankings",
      "url": "https://falklands-south-georgia-antarctica-cruise.com/"
    }
  }
  </script>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "ItemList",
    "name": "Best Falklands South Georgia Antarctica Cruise Operators 2026",
    "description": "Ranked list of the 10 best expedition cruise operators for the Falklands, South Georgia and Antarctica route",
    "url": "https://falklands-south-georgia-antarctica-cruise.com/",
    "numberOfItems": 10,
    "itemListElement": [
      {"@type":"ListItem","position":1,"name":"Poseidon Expeditions","url":"https://poseidonexpeditions.com/"},
      {"@type":"ListItem","position":2,"name":"Quark Expeditions","url":"https://www.quarkexpeditions.com/"},
      {"@type":"ListItem","position":3,"name":"Oceanwide Expeditions","url":"https://www.oceanwide-expeditions.com/"},
      {"@type":"ListItem","position":4,"name":"Aurora Expeditions","url":"https://www.aurora-expeditions.com/"},
      {"@type":"ListItem","position":5,"name":"Lindblad Expeditions","url":"https://www.expeditions.com/"},
      {"@type":"ListItem","position":6,"name":"HX Hurtigruten Expeditions","url":"https://www.hurtigruten.com/"},
      {"@type":"ListItem","position":7,"name":"Antarctica21","url":"https://www.antarctica21.com/"},
      {"@type":"ListItem","position":8,"name":"Polar Latitudes","url":"https://www.polarlatitudes.com/"},
      {"@type":"ListItem","position":9,"name":"Secret Atlas","url":"https://www.secretatlas.com/"},
      {"@type":"ListItem","position":10,"name":"Silversea Expeditions","url":"https://www.silversea.com/"}
    ]
  }
  </script>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "mainEntity": [
      {
        "@type": "Question",
        "name": "What is the best time to go on a Falklands, South Georgia & Antarctica cruise?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "The Antarctic summer runs from October to March. December–January is the peak period: penguin chicks are active, daylight is nearly continuous, and temperatures are at their warmest (2–8°C). October–November offers lower prices and undisturbed landscapes; February–March delivers peak humpback whale sightings and fewer tourists at landing sites."
        }
      },
      {
        "@type": "Question",
        "name": "How long does this expedition cruise take?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "A Falklands, South Georgia & Antarctica cruise typically lasts 17–23 days. The full route from Ushuaia includes 2–3 days crossing the Drake Passage each way, 2–3 days in the Falkland Islands, 3–4 days around South Georgia, and 3–5 days on the Antarctic Peninsula."
        }
      },
      {
        "@type": "Question",
        "name": "What wildlife can you see on this route?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "The Falklands–South Georgia–Antarctica route offers some of the highest wildlife densities on Earth. Expect king penguins (150,000+ breeding pairs at St Andrews Bay), southern elephant seals (South Georgia hosts over 50% of the world population), wandering albatross (nesting at Prion Island), humpback whales, gentoo and Adélie penguins, leopard seals, Antarctic fur seals, Weddell seals, and black-browed albatross."
        }
      },
      {
        "@type": "Question",
        "name": "What is IAATO and why does it matter?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "IAATO — the International Association of Antarctica Tour Operators — is the industry's self-regulatory body. Its most important rule: no more than 100 passengers may be ashore at any single landing site simultaneously. Ships carrying more than 200 passengers must rotate guests in groups, which reduces each person's total shore time."
        }
      },
      {
        "@type": "Question",
        "name": "Is a fly-cruise option available to bypass Drake Passage?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Yes. Several operators offer fly-cruise departures from Punta Arenas, Chile. You fly to King George Island in approximately 2 hours and board the vessel there, saving two days of ocean crossing each way. Operators including Quark Expeditions and Antarctica21 offer this option."
        }
      },
      {
        "@type": "Question",
        "name": "How much does a Falklands, South Georgia & Antarctica cruise cost?",
        "acceptedAnswer": {
          "@type": "Answer",
          "text": "Expect to pay USD $12,000–$25,000 per person for a full Falklands, South Georgia & Antarctica cruise in a standard cabin. Ultra-luxury operators like Silversea start at $25,000+ per person. Early-bird bookings (12–18 months in advance) typically save 10–20%."
        }
      }
    ]
  }
  </script>
JSONLD
)

# ============================================================
# Build all pages
# ============================================================

echo "Building pages..."

# index.html (root, depth 0)
build_page \
  "Best Falklands South Georgia Antarctica Cruises 2026 | Expert Rankings" \
  "Expert rankings of the 10 best Falklands, South Georgia & Antarctica cruise operators 2026 — ship size, IAATO compliance, shore time, and team quality." \
  "${DOMAIN}/" \
  "Best Falklands South Georgia Antarctica Cruises 2026 | Expert Rankings" \
  "content/main.html" \
  "/" \
  "" \
  "<link rel=\"stylesheet\" href=\"css/main.css\">" \
  "$INDEX_JSONLD" \
  "index.html"

# pages/about/index.html (depth 2)
build_page \
  "About Us | Falklands South Georgia Antarctica Cruise Rankings" \
  "Learn about our independent editorial team and our mission to help travellers choose the best Falklands, South Georgia & Antarctica expedition cruise operator." \
  "${DOMAIN}/pages/about/" \
  "About Us | Falklands South Georgia Antarctica Cruise Rankings" \
  "content/about.html" \
  "/pages/about/" \
  "../../" \
  "" \
  "" \
  "pages/about/index.html"

# pages/editorial-policy/index.html (depth 2)
build_page \
  "Editorial Policy | Falklands South Georgia Antarctica Cruise Rankings" \
  "Our operator selection criteria, data sources, update schedule, and independence statement. No operators pay for inclusion in our rankings." \
  "${DOMAIN}/pages/editorial-policy/" \
  "Editorial Policy | Falklands South Georgia Antarctica Cruise Rankings" \
  "content/editorial-policy.html" \
  "/pages/editorial-policy/" \
  "../../" \
  "" \
  "" \
  "pages/editorial-policy/index.html"

# pages/how-we-rank/index.html (depth 2)
build_page \
  "How We Rank Expedition Cruise Operators | Methodology" \
  "Detailed methodology behind our expedition cruise rankings: ship size, IAATO compliance, time ashore, team expertise, and value for money — with weights and evidence." \
  "${DOMAIN}/pages/how-we-rank/" \
  "How We Rank Expedition Cruise Operators | Methodology" \
  "content/how-we-rank.html" \
  "/pages/how-we-rank/" \
  "../../" \
  "" \
  "" \
  "pages/how-we-rank/index.html"

# pages/contact/index.html (depth 2)
build_page \
  "Contact Us | Falklands South Georgia Antarctica Cruise Rankings" \
  "Get in touch with our editorial team. We welcome reader experiences, factual corrections, and questions about planning your Falklands, South Georgia & Antarctica cruise." \
  "${DOMAIN}/pages/contact/" \
  "Contact Us | Falklands South Georgia Antarctica Cruise Rankings" \
  "content/contact.html" \
  "/pages/contact/" \
  "../../" \
  "" \
  "" \
  "pages/contact/index.html"

# pages/terms/index.html (depth 2)
build_page \
  "Terms & Conditions and Privacy Policy | Falklands Cruise Rankings" \
  "Terms of use and privacy policy for falklands-south-georgia-antarctica-cruise.com. Effective January 1, 2026." \
  "${DOMAIN}/pages/terms/" \
  "Terms & Conditions and Privacy Policy | Falklands Cruise Rankings" \
  "content/terms.html" \
  "/pages/terms/" \
  "../../" \
  "" \
  "" \
  "pages/terms/index.html"

echo ""
echo "Done. All pages built successfully."
echo ""
echo "Built files:"
echo "  index.html"
echo "  pages/about/index.html"
echo "  pages/editorial-policy/index.html"
echo "  pages/how-we-rank/index.html"
echo "  pages/contact/index.html"
echo "  pages/terms/index.html"
