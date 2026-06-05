# Traction — Aarogya Vault

> **Note:** This document reflects verified achievements from the repository and deployment state. No user counts, revenue figures, download numbers, or partnership claims are included. Future metric sections are templates for data to be collected during beta.

---

## Current Achievements

### Product Development

| Achievement | Status | Details |
|-------------|--------|---------|
| MVP completed | ✅ | Full upload → storage → OCR → Firestore pipeline implemented |
| Flutter Android app | ✅ | Auth, dashboard, upload, document list, delete, OCR data layer |
| Google Sign-In | ✅ | Firebase Auth + Google OAuth via `GoogleAuthService` |
| Document upload flow | ✅ | PDF, JPG, JPEG, PNG via file picker; 7 document types |
| Firestore integration | ✅ | `users`, `documents`, `ocr_results` collections |
| Storage integration | ✅ | Per-user paths in Firebase Cloud Storage |
| OCR results retrieval | ✅ | `FirestoreOcrRepository` with stream providers |
| User profile system | ✅ | Firestore user bootstrap on authentication |

### Backend & AI

| Achievement | Status | Details |
|-------------|--------|---------|
| Firebase Cloud Functions deployed | ✅ | `onDocumentUploaded` storage trigger (v2) |
| Gemini OCR pipeline | ✅ | `GeminiOcrProvider` using `gemini-2.5-flash` |
| OCR results in Firestore | ✅ | `extractedText` + `summary` persisted |
| Duplicate OCR protection | ✅ | Skips processing if result already exists |
| File size validation | ✅ | 10 MB maximum |
| MIME whitelist | ✅ | `application/pdf`, `image/jpeg`, `image/png` |
| Cost safeguards | ✅ | No automatic retry policy on OCR failure |

### Website & Go-to-Market

| Achievement | Status | Details |
|-------------|--------|---------|
| Production landing page | ✅ | Full startup website with 12+ sections |
| Custom domain live | ✅ | https://aarogyavault.live |
| Firebase Hosting deployed | ✅ | Static site with security headers, caching |
| SEO setup | ✅ | Meta tags, Open Graph, JSON-LD, sitemap, robots.txt |
| Privacy Policy | ✅ | `/privacy` |
| Terms of Service | ✅ | `/terms` |
| Waitlist active | ✅ | Firestore `waitlist` collection with validated create rules |
| MVP transparency | ✅ | Public MVP status, Gemini AI, and GCP architecture sections |
| Founder story published | ✅ | On website and in application docs |

### Engineering Discipline

| Achievement | Status | Details |
|-------------|--------|---------|
| Monorepo structure | ✅ | `apps/`, `backend/`, `website/` |
| Version control milestones | ✅ | Tagged releases from `v0.1.0-foundation` through `v0.1-google-startups-checkpoint` |
| Firestore security rules | ✅ | Owner-only access for user data |
| Unified Firebase config | ✅ | Root `firebase.json` for hosting, functions, firestore, storage |

---

## Current Operational Status

| Item | Status |
|------|--------|
| OCR processing | ⏸ Paused — Google Cloud / Gemini API credits exhausted |
| Code / deployment blockers | None identified |
| In-app summary viewer | In development |
| Google Play listing | Not yet published |
| iOS app | Not yet published |
| Product demo video | Placeholder on website |

---

## Future Metrics (To Be Tracked)

The following metrics will be measured once beta testing begins. **No values are reported at this stage.**

### Waitlist Signups

| Metric | Target (Beta) | How Measured |
|--------|---------------|--------------|
| Total signups | TBD | Firestore `waitlist` collection count |
| Weekly signups | TBD | `createdAt` timestamp aggregation |
| Signup source | TBD | `source` field (currently `"website"`) |

**Collection method:** Firebase Console → Firestore → `waitlist`  
**Future improvement:** Admin dashboard or Cloud Function analytics export

---

### Beta Users

| Metric | Target (Beta) | How Measured |
|--------|---------------|--------------|
| Invited beta users | TBD | Manual invite tracking |
| Activated accounts | TBD | Firebase Auth user count |
| Users with ≥1 upload | TBD | Firestore `documents` query by `ownerId` |
| Retention (7-day) | TBD | Auth + document activity timestamps |

**Planned beta start:** Q3 2026 (per roadmap)

---

### Documents Processed

| Metric | Target (Beta) | How Measured |
|--------|---------------|--------------|
| Total uploads | TBD | Firestore `documents` collection count |
| OCR success rate | TBD | `ocr_results` count vs. upload count |
| OCR failure rate | TBD | Cloud Functions error logs |
| Avg. processing time | TBD | Cloud Functions execution duration logs |
| Document type distribution | TBD | `documentType` field aggregation |

**Collection method:** Firestore queries + Cloud Functions logs in Google Cloud Console

---

### Monthly Active Users (MAU)

| Metric | Target (Post-Launch) | How Measured |
|--------|----------------------|--------------|
| MAU | TBD | Firebase Analytics (not yet integrated) |
| DAU / MAU ratio | TBD | Firebase Analytics |
| Sessions per user | TBD | Firebase Analytics |
| Documents per active user | TBD | Firestore aggregation |

**Planned instrumentation:** Firebase Analytics integration (listed in website future improvements)

---

## Traction Summary

**What exists today:** A deployed, code-complete MVP with live website, working authentication, document management, and a Gemini OCR pipeline — paused only by cloud credit limits.

**What does not exist yet:** Published user metrics, revenue, app store downloads, or beta cohort data. These will be the primary traction signals to establish during the beta phase.

**Next traction milestone:** Resume OCR processing with cloud credits → onboard first beta users → publish first measurable metrics in this document.
