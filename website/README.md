# Aarogya Vault — Marketing Website

Production landing page for [aarogyavault.live](https://aarogyavault.live), built with static HTML, CSS, and vanilla JavaScript for optimal performance on Firebase Hosting.

## Project Structure

```
website/
├── README.md
└── public/
    ├── index.html          # Landing page (MVP status, Gemini AI, GCP platform, demo video, etc.)
    ├── privacy/index.html  # Privacy Policy
    ├── terms/index.html    # Terms of Service
    ├── css/styles.css      # All styles
    ├── js/
    │   ├── main.js         # Navigation, scroll animations
    │   ├── waitlist.js     # Firestore waitlist integration
    │   └── firebase-config.js
    ├── favicon.svg
    ├── robots.txt
    └── sitemap.xml
```

## Local Development

Serve the `public/` directory with any static file server:

```bash
# Option 1: Firebase emulator (recommended — matches production)
firebase emulators:start --only hosting

# Option 2: Python
cd website/public && python3 -m http.server 8080

# Option 3: npx
npx serve website/public -p 8080
```

Open [http://localhost:5000](http://localhost:5000) (Firebase) or [http://localhost:8080](http://localhost:8080).

## Deployment to Firebase Hosting

### Prerequisites

1. [Firebase CLI](https://firebase.google.com/docs/cli) installed: `npm install -g firebase-tools`
2. Logged in: `firebase login`
3. Project linked (already configured): `aarogya-vault-dev`

### Deploy

From the **repository root**:

```bash
# Deploy hosting only
firebase deploy --only hosting

# Deploy hosting + updated Firestore rules (required for waitlist)
firebase deploy --only hosting,firestore:rules
```

### Custom Domain (aarogyavault.live)

1. Open [Firebase Console → Hosting](https://console.firebase.google.com/project/aarogya-vault-dev/hosting)
2. Click **Add custom domain**
3. Enter `aarogyavault.live`
4. Add the DNS records Firebase provides to your domain registrar:
   - **A records** pointing to Firebase IPs, or
   - **CNAME** for `www` subdomain
5. Wait for SSL certificate provisioning (usually minutes to hours)

Also add `www.aarogyavault.live` and set up a redirect to the apex domain if desired.

## Waitlist Integration

Submissions are stored in Firestore collection `waitlist`:

| Field       | Type      | Description              |
|-------------|-----------|--------------------------|
| `name`      | string    | User's full name         |
| `email`     | string    | Email address (lowercase)|
| `createdAt` | timestamp | Server timestamp         |
| `source`    | string    | Always `"website"`       |

### Viewing Submissions

1. [Firebase Console → Firestore](https://console.firebase.google.com/project/aarogya-vault-dev/firestore)
2. Open the `waitlist` collection

### Security Rules

Rules in `apps/mobile_app/firestore.rules` allow:
- **Create**: Unauthenticated users from the website (validated fields only)
- **Read/Update/Delete**: Denied (admin access via Firebase Console only)

**Deploy rules after changes:**

```bash
firebase deploy --only firestore:rules
```

### Alternative: Cloud Function Endpoint

For rate limiting, email validation, or duplicate detection, replace direct Firestore writes with a Cloud Function HTTP endpoint. See "Future Improvements" below.

## SEO

- Title, meta description, Open Graph, and Twitter Card tags on all pages
- JSON-LD structured data (Organization, WebSite, SoftwareApplication)
- `robots.txt` and `sitemap.xml`
- Semantic HTML with ARIA labels
- Canonical URLs set to `https://aarogyavault.live`

Submit sitemap to [Google Search Console](https://search.google.com/search-console) after domain is live.

## Performance

- No build step — static files served directly
- System font stack with Inter via Google Fonts (preconnected)
- CSS/JS cache headers configured in `firebase.json`
- SVG illustrations (no heavy image assets)
- Lighthouse-optimized: minimal JS, no frameworks

## Future Improvements

1. **OG Image** — Add a 1200×630 `og-image.png` for social sharing previews
2. **Real Screenshots** — Replace phone mockup placeholders with actual app screenshots
3. **Analytics** — Add Firebase Analytics or Plausible for traffic insights
4. **Rate Limiting** — Move waitlist to a Cloud Function with reCAPTCHA
5. **Email Notifications** — Trigger email to founder on new waitlist signup via Cloud Function
6. **Blog / Changelog** — Add `/blog` for SEO content and product updates
7. **App Store Links** — Add download CTAs when mobile app is published
8. **i18n** — Hindi localization for Indian market
9. **A/B Testing** — Test hero copy and CTA placement
10. **Production Firebase Project** — Separate `aarogya-vault-prod` for production vs dev

## Google for Startups Application Tips

When applying for Google for Startups Cloud Program, reference:

- **Live website**: https://aarogyavault.live
- **MVP evidence**: Working Android app, Cloud Function OCR pipeline, Gemini 2.5 Flash integration
- **Tech stack**: Flutter, Firebase Auth, Firestore, Cloud Storage, Cloud Functions, Gemini AI, Firebase Hosting
- **Use case**: AI healthcare startup — healthcare document management with medical OCR for India
- **Stage**: MVP Available → Beta Testing (Q3 2026) → Public Launch (Q4 2026)
- **Cloud usage**: 6 Google services in production (see `#platform` section on site)
- **Demo video**: Replace placeholder at `#demo` with Loom/YouTube walkthrough before submitting
