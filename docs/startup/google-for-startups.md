# Aarogya Vault — Google for Startups Cloud Program Application

**Company:** Aarogya Vault  
**Founder:** Amrit Kumar  
**Website:** https://aarogyavault.live  
**Contact:** amrit@aarogyavault.live  
**Location:** India  
**Stage:** Bootstrapped MVP  
**Repository checkpoint:** `v0.1-google-startups-checkpoint`  
**Firebase Project:** `aarogya-vault-dev`

---

## Executive Summary

Aarogya Vault is an AI healthcare startup building a personal health document management platform for India. The product allows individuals to securely store medical reports, prescriptions, and diagnostic documents, automatically extract text using Gemini AI medical OCR, and receive patient-readable summaries.

The MVP is built and deployed on Google Cloud and Firebase: a Flutter Android app, Firebase Authentication, Cloud Firestore, Cloud Storage, Cloud Functions, Gemini 2.5 Flash, and Firebase Hosting with a live startup website at aarogyavault.live.

Aarogya Vault is applying for Google for Startups Cloud credits to resume and scale Gemini OCR processing, which is currently paused due to exhausted cloud/API credits — not due to technical blockers.

---

## Problem Statement

In India, patients accumulate healthcare documents across disconnected providers:

- Lab reports from diagnostic chains
- Prescriptions from clinics and pharmacies
- Discharge summaries from hospitals
- Insurance and vaccination records

These documents are scattered across paper files, WhatsApp forwards, email attachments, and hospital-specific portals. Patients cannot easily store, search, or understand their own medical history. Medical terminology in reports is written for clinicians, not patients, creating a comprehension gap that affects continuity of care.

There is no unified, patient-owned layer for personal health records that combines secure storage with AI-powered document understanding.

---

## Solution Overview

Aarogya Vault provides:

1. **Secure document vault** — Upload and store healthcare documents (PDF, JPEG, PNG) in Firebase Cloud Storage with per-user isolation.
2. **Medical OCR pipeline** — Cloud Function triggered on upload processes documents through Gemini 2.5 Flash.
3. **AI summaries** — Structured JSON output with `extractedText` and patient-readable `summary` stored in Firestore.
4. **Mobile access** — Flutter Android app with Google Sign-In, document library, upload flow, and OCR result retrieval layer.
5. **Public presence** — Production website with waitlist, legal pages, and MVP transparency for early user acquisition.

**Supported document types (MVP):** Prescription, Lab Report, Vaccination, Insurance, Discharge Summary, Medical Certificate, Other.

**Important disclaimer:** Aarogya Vault is not a medical device. AI summaries are informational only and do not constitute medical advice. No regulatory compliance claims are made.

---

## Why Now

The timing is driven by shifts in patient behaviour and healthcare delivery in India — not by technology availability alone.

### Patients are receiving more digital health documents than ever

Diagnostic chains, hospitals, and clinics increasingly deliver reports as **PDFs and images** rather than paper alone. Patients share these via WhatsApp, email, and messaging apps — but have no personal system to organise them. The volume of digital medical documents per household is rising, while the tools patients use to manage them (camera rolls, chat threads, email folders) were never designed for healthcare.

### Digital health adoption is accelerating, but ownership remains fragmented

Teleconsultation, online pharmacy, and digital diagnostics have normalised receiving health information on a phone. Yet each provider operates its own silo: a lab portal for Thyrocare results, a hospital app for discharge summaries, a clinic WhatsApp for prescriptions. **Patients are more digitally connected to healthcare, but less able to own a unified record of it.**

### Patient ownership of health data is becoming an expectation

Regulatory direction globally — and patient sentiment in India — is moving toward individuals having greater access to their own health information. Patients increasingly expect to carry their history across providers, share records with family members, and understand what their reports mean. The demand is for a **patient-controlled archive**, not another provider-locked portal.

### AI accessibility lowers the comprehension barrier — at the right moment

Multimodal AI models can now extract and summarise medical document text from the PDFs and images patients already receive. This does not create the market need — it **removes a barrier** that previously made personal health record management impractical at scale. Before accessible AI, storing documents was possible; understanding them still required clinical literacy.

### Why this window matters

The gap between "receiving digital health documents" and "understanding and managing them" is widening as document volume grows. Aarogya Vault is positioned at that gap: **after** patients receive reports digitally, **before** they lose, forget, or fail to understand them. Building now means serving a behaviour change already underway — not waiting for a future market to form.

---

## Target Market

**Primary:** Health-conscious individuals and families in India who manage their own medical records across multiple providers.

**Initial use cases:**

- Storing lab reports and prescriptions in one place
- Understanding complex medical reports through AI summaries
- Preparing documents before doctor visits or second opinions
- Maintaining a personal health document archive over time

**Geography:** India-first (Hindi product name *Aarogya* = health; domain aarogyavault.live).

---

## Market Opportunity in India

India presents a structurally favourable environment for a patient-owned health document platform — not because of a single large number, but because of how healthcare is consumed and documented.

### Why start with India

**Large population, diverse healthcare consumption.** India has one of the world's largest patient populations, with care delivered across private hospitals, government facilities, standalone diagnostic chains, and local clinics. A typical patient interacts with multiple providers over a lifetime — each generating documents in different formats, with no shared record.

**Mobile-first internet adoption.** Healthcare documents in India increasingly arrive on smartphones — as PDF attachments, photographed prescriptions, or lab report images shared in family WhatsApp groups. A mobile-native product meets patients where their documents already live, rather than asking them to adopt desktop workflows.

**Fragmented healthcare records by design.** Hospital EMRs, lab portals, and clinic systems were built for provider operations — not patient portability. When a patient switches doctors, moves cities, or manages a parent's care, they carry paper folders and phone galleries, not a unified history. The fragmentation is structural, not incidental.

**Growing digital health ecosystem.** Digital diagnostics, telemedicine, and online health services are expanding the volume of patient-generated and patient-received documents. Each new digital touchpoint adds another document source — and another silo — unless patients have a personal layer to consolidate them.

Aarogya Vault addresses the **personal health record gap** — the missing layer between provider-generated documents and patient understanding. Rather than replacing hospital EMRs or competing with lab portals, it gives individuals a place to collect, store, and understand documents from *any* provider.

*Note: Specific market size figures are not claimed in this application. Sizing will be validated during beta testing.*

---

## Current MVP Status

### Shipped and Working

| Component | Status | Evidence |
|-----------|--------|----------|
| Google Sign-In | ✅ Live | `GoogleAuthService`, Firebase Auth |
| Document upload (PDF/JPG/PNG) | ✅ Live | `DashboardScreen`, `FirestoreDocumentService` |
| Firebase Cloud Storage | ✅ Live | Per-user path: `documents/{userId}/{documentId}.{ext}` |
| Firestore document metadata | ✅ Live | `documents` collection with security rules |
| Cloud Function OCR trigger | ✅ Deployed | `onDocumentUploaded` (Storage v2 trigger) |
| Gemini 2.5 Flash integration | ✅ Implemented | `GeminiOcrProvider` |
| OCR result storage | ✅ Live | `ocr_results` collection in Firestore |
| Duplicate OCR protection | ✅ Live | Skips if `ocr_results` doc exists |
| File size validation | ✅ Live | 10 MB limit |
| MIME whitelist | ✅ Live | PDF, JPEG, PNG only |
| OCR retrieval layer (Flutter) | ✅ Built | `FirestoreOcrRepository`, stream providers |
| User profiles | ✅ Live | `users` collection |
| Startup website | ✅ Deployed | https://aarogyavault.live |
| Waitlist | ✅ Active | Firestore `waitlist` collection |
| Legal pages | ✅ Live | `/privacy`, `/terms` |

### In Active Development

| Component | Status |
|-----------|--------|
| In-app OCR summary viewer | UI screen in development |
| Product demo video | Placeholder on website |
| iOS release | Not yet published |
| Smart search | Roadmap |

### Current Blocker

OCR processing is **technically complete** but **operationally paused** due to exhausted Google Cloud / Gemini API credits. Resuming requires cloud credits — the primary reason for this application.

---

## Technical Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                            │
│  Flutter Android App (Riverpod, GoRouter)                   │
│  Firebase Hosting Website (aarogyavault.live)               │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                     BACKEND LAYER                           │
│  Firebase Authentication (Google Sign-In)                   │
│  Cloud Firestore (users, documents, ocr_results, waitlist)  │
│  Firebase Cloud Storage (document files)                    │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                  COMPUTE & AI LAYER                         │
│  Cloud Functions v2 (onDocumentUploaded)                    │
│  Google Gemini 2.5 Flash API (medical OCR + summary)      │
│  Google Cloud Platform (underlying infrastructure)          │
└─────────────────────────────────────────────────────────────┘
```

### OCR Pipeline Flow

1. User uploads document via Flutter app
2. File stored at `documents/{userId}/{documentId}.{extension}`
3. `onDocumentFinalized` triggers Cloud Function
4. Function validates MIME type, file size, and storage path
5. Function checks for existing OCR result (duplicate protection)
6. Document downloaded and sent to Gemini 2.5 Flash
7. Structured JSON parsed: `extractedText` + `summary`
8. Results saved to `ocr_results/{documentId}`

### Security Model

- Firebase Auth required for all user data access
- Firestore rules enforce owner-only read/write on `users` and `documents`
- Waitlist allows public create only (validated fields, no reads)
- No automatic retry policy on OCR failures (cost safeguard)

### Monorepo Structure

```
aarogya-vault/
├── apps/mobile_app/       # Flutter frontend
├── backend/functions/     # Cloud Functions (TypeScript)
├── website/public/        # Firebase Hosting
└── firebase.json          # Unified Firebase config
```

---

## AI / Gemini Usage

**Model:** `gemini-2.5-flash`  
**SDK:** `@google/genai`  
**Integration:** `GeminiOcrProvider` in Cloud Functions

**Prompt design:** Purpose-built OCR prompt instructs Gemini to:
1. Extract all visible text exactly as written
2. Create a concise medical summary
3. Return structured JSON only

**Input types:** PDF, JPEG, PNG (base64 inline data)  
**Output schema:**
```json
{
  "extractedText": "...",
  "summary": "..."
}
```

**Cost safeguards implemented:**
- 10 MB file size cap
- MIME type whitelist
- Duplicate OCR skip
- No automatic retry on failure
- Secret-managed API key (`GEMINI_API_KEY`)

---

## Competitive Differentiation

Aarogya Vault operates in a space where patients already use imperfect substitutes. The differentiation is architectural and intentional — not a claim of superiority over established systems.

### Hospital portals

**What they do:** Provide access to records from a single hospital or health network.  
**Limitation for patients:** Records are locked to one provider. When care happens across multiple hospitals — common in India — patients must log into separate systems or collect printouts. Portals serve the hospital's workflow, not the patient's full history.  
**Aarogya Vault's position:** Provider-agnostic. Patients upload documents from *any* hospital into one personal vault. Complements portals; does not replace hospital systems.

### Diagnostic lab portals

**What they do:** Deliver test results from a specific lab chain (e.g., Thyrocare, Dr. Lal PathLabs).  
**Limitation for patients:** Each chain has its own portal or PDF delivery. Results from different labs over years have no unified view. Reports are often delivered without explanation of clinical terms.  
**Aarogya Vault's position:** Consolidates lab reports from any source and adds AI-generated summaries to aid comprehension. Patients retain records even if a lab changes its portal or report format.

### Cloud storage apps (Google Drive, Dropbox, phone gallery)

**What they do:** Store files generically.  
**Limitation for patients:** No healthcare context — no document typing (prescription vs. lab report), no OCR tuned for medical text, no summaries, no health-specific organisation. Medical documents become indistinguishable from other files in a folder.  
**Aarogya Vault's position:** Purpose-built for healthcare documents with typed categories, medical OCR, and AI summaries — not generic file storage.

### Generic OCR tools

**What they do:** Extract text from images or PDFs.  
**Limitation for patients:** No medical context in extraction, no summary generation, no secure health-specific storage, no mobile-first upload flow integrated with authentication and per-user data isolation.  
**Aarogya Vault's position:** End-to-end healthcare pipeline — upload, typed storage, Gemini medical OCR, summary, and secure retrieval in one product. OCR is a step in a workflow, not the product itself.

### Summary of differentiation

| Category | Patient pain | Aarogya Vault approach |
|----------|-------------|------------------------|
| Hospital portals | Single-provider lock-in | Multi-provider personal vault |
| Lab portals | Fragmented test history | Unified lab report archive + summaries |
| Cloud storage | No health context | Healthcare-typed document management |
| Generic OCR | Text only, no understanding | OCR + AI medical summary pipeline |

**Architectural differentiator (evidence-based):** A deployed pipeline from mobile upload → Cloud Storage trigger → Gemini 2.5 Flash OCR → Firestore persistence, built entirely on Google Cloud. This is an integrated healthcare document workflow — not a chatbot wrapper or a generic storage app with OCR bolted on.

---

## Founder Background

**Amrit Kumar** — Founder & CEO, Aarogya Vault

### Engineering foundation

Amrit holds a background in **Electronics & Computer Engineering**, combining systems-level thinking with software development. This foundation informs how Aarogya Vault is architected: event-driven pipelines, strict input validation (MIME whitelist, file size caps), and security rules that enforce data isolation at the infrastructure layer — not as an afterthought.

### Production software experience

Amrit has hands-on experience building and shipping production software across the full stack:

- **Flutter** — Mobile app architecture with Riverpod state management and GoRouter navigation
- **Firebase / Google Cloud** — Authentication, Firestore, Cloud Storage, Cloud Functions, Hosting
- **TypeScript backend** — Serverless OCR pipeline with structured error handling and cost safeguards
- **Gemini AI integration** — Multimodal document processing with JSON-schema output parsing

The Aarogya Vault MVP was built end-to-end by the founder: mobile client, backend functions, AI integration, security rules, and public website. This is not a prototype outsourced to contractors — it is a deployed, tagged, reviewable codebase (`v0.1-google-startups-checkpoint`).

### Why healthcare document management

The focus on healthcare documents emerged from direct observation: in India, family members routinely struggle to organise and understand medical reports across providers. When a relative needed repeated help interpreting blood test results, the problem became personal. Medical documents are written for clinicians. Patients — especially in households managing care for parents or children — need a system that stores, organises, and explains those documents in plain language.

Amrit's technical skills map directly to this problem: mobile upload UX (Flutter), secure per-user storage (Firebase), automated processing (Cloud Functions), and document comprehension (Gemini). The founder is not adjacent to the problem — he built the exact stack the problem requires.

### Why bootstrap

Aarogya Vault was bootstrapped deliberately. Without external funding, every architectural decision had to be cost-conscious: duplicate OCR protection, no automatic retry policies, MIME whitelists, and a serverless model that scales to zero. Bootstrapping forced discipline — ship a working MVP on Google Cloud's free tier and paid credits, validate the pipeline, then seek infrastructure support (Google for Startups) to scale.

Bootstrapping also kept the product focused. Without investor pressure to expand scope prematurely, the MVP delivers one complete loop: upload → OCR → summary → storage. That focus produced a tagged checkpoint ready for external review.

### Founder–market fit

| Factor | Fit |
|--------|-----|
| Market | India-based founder building for Indian patients |
| Technical skills | Flutter + Firebase + Gemini — the exact MVP stack |
| Problem proximity | Personal experience with family healthcare document confusion |
| Execution evidence | Solo-built, deployed MVP with live website and git checkpoint |
| Infrastructure choice | Google Cloud from day one — aligned with this application |

See `founder-story.md` for the full narrative.

---

## Current Stage

| Milestone | Status |
|-----------|--------|
| Foundation (auth, routing, Firebase) | ✅ Complete |
| Document upload & storage | ✅ Complete |
| OCR pipeline & Gemini integration | ✅ Complete |
| Startup website & domain | ✅ Complete |
| Git checkpoint (`v0.1-google-startups-checkpoint`) | ✅ Tagged |
| Beta testing | 🔜 Planned Q3 2026 |
| Public launch (Google Play) | 🔜 Planned Q4 2026 |

**Funding:** Bootstrapped (no external funding claimed)  
**Team:** Founder-led MVP

---

## Planned Milestones

| Phase | Timeline | Goal |
|-------|----------|------|
| Beta Testing | Q3 2026 | Onboard waitlist users, ship in-app summary viewer |
| Public Launch | Q4 2026 | Google Play release, production Firebase project |
| AI Health Insights | 2027 | Trend analysis across uploaded documents |
| Family Health Management | 2027 | Multi-member vaults |
| Ecosystem Integrations | 2028+ | Lab and hospital connectivity |

See `roadmap.md` for detailed milestones.

---

## Long-Term Vision

Aarogya Vault is designed as a progressive platform — each phase builds on verified capability from the previous one, not speculative features.

### 1. Personal Document Vault (Current — MVP Live)

Patients upload and store medical documents from any provider. Gemini OCR extracts text and generates summaries. This is the foundation: **if patients cannot reliably store and understand a single document, nothing else matters.**

*Status: Shipped. OCR paused pending cloud credits.*

### 2. AI Medical Understanding (Beta → Launch)

Move from per-document summaries to cross-document context. Help patients see patterns across lab reports over time, understand trends in recurring prescriptions, and build a readable health narrative from their uploaded archive.

*Dependency: Sufficient document volume from beta users and reliable OCR processing.*

### 3. Family Health Records (Post-Launch)

Enable vaults for family members — parents, children, dependents — managed from a single account. In India, healthcare document management is often a family responsibility, not an individual one.

*Dependency: Proven single-user retention and security model at scale.*

### 4. Healthcare Intelligence Layer (Long-Term)

Become the personal health record layer that connects patient-owned data with the broader digital health ecosystem — lab integrations, hospital discharge imports, and structured health data portability. Not replacing provider systems, but sitting above them as the patient-controlled intelligence layer.

*Dependency: User base, provider partnerships, and regulatory clarity. No partnerships exist today.*

> "To become the personal health record layer for the next billion people."

This vision is aspirational and staged. Each step is gated by measurable milestones — not timeline promises alone.

---

## Impact Potential

Aarogya Vault is early-stage. Impact claims are directional, based on the problem being solved — not on measured outcomes yet.

### Patient understanding

Medical reports use terminology that most patients cannot interpret independently. AI-generated summaries — clearly marked as informational, not medical advice — can reduce the comprehension gap between receiving a report and understanding what it contains. Impact: patients arrive at consultations better prepared, with clearer questions.

### Healthcare continuity

When patients switch doctors, move cities, or manage chronic conditions over years, fragmented records lead to repeated tests and incomplete clinical context. A personal document vault gives patients a portable archive they control. Impact: smoother care transitions and reduced reliance on memory or physical file folders.

### Document accessibility

Documents trapped in WhatsApp chats, email inboxes, or provider portals are effectively lost when phones change, accounts close, or portals redesign. Centralised, cloud-backed storage with mobile access makes health documents retrievable when needed — including during emergencies or family caregiving situations.

### India-first healthcare infrastructure

India's healthcare system will not be unified by a single national EMR. Patient-owned infrastructure — built mobile-first, designed for PDF and image reports common in Indian diagnostics — addresses how healthcare is actually consumed. Aarogya Vault contributes a layer that respects local behaviour (WhatsApp-shared reports, multi-provider care) rather than imposing foreign workflows.

**What we do not claim:** Improved health outcomes, reduced mortality, regulatory compliance, hospital cost savings, or any quantified impact metrics. These require clinical studies and user data we do not yet have. Impact will be measured and reported honestly as beta data becomes available.

---

## How Google Cloud Credits Will Be Used

Credits will be allocated across the services already in production:

### 1. Gemini API (Priority — Immediate)

- Resume medical OCR processing for uploaded documents
- Support beta user document volume
- Estimated primary credit consumer

### 2. Cloud Functions

- `onDocumentUploaded` execution time and invocations
- Scale with beta upload volume

### 3. Firebase Cloud Storage

- Document file storage for beta users
- Egress for Cloud Function downloads

### 4. Cloud Firestore

- Document metadata, OCR results, user profiles, waitlist
- Read/write operations scaling with users

### 5. Firebase Hosting

- Continue serving aarogyavault.live
- SSL, CDN, custom domain

### 6. Firebase Authentication

- Google Sign-In sessions for beta cohort

### Future (Post-Credits)

- Separate production Firebase project (`aarogya-vault-prod`)
- Firebase Analytics for usage insights
- Potential Cloud Run migration for heavier AI workloads

**Immediate need:** Unblock Gemini OCR processing to demonstrate full pipeline to beta users and application reviewers.

---

## Why Aarogya Vault Fits Google for Startups

1. **Built on Google Cloud from day one** — Not migrating to Google; already deployed on Firebase, Cloud Functions, Gemini, and Hosting.

2. **AI-native healthcare use case** — Gemini is core to the product, not an add-on feature.

3. **Working MVP with clear evidence** — Live website, deployed functions, tagged repository checkpoint, documented architecture.

4. **Scalable serverless architecture** — Designed to grow from founder-led MVP to beta without re-architecting.

5. **India market alignment** — Building healthcare infrastructure for a large, underserved patient population.

6. **Credit utilization is immediate and specific** — Credits directly unblock a paused production pipeline (OCR), not speculative R&D.

7. **Alignment with Google Health / AI mission** — Making medical documents understandable for everyday people using Google's AI capabilities.

---

## Supporting Materials

| Asset | Location |
|-------|----------|
| Live website | https://aarogyavault.live |
| Source code | GitHub (private): checkpoint `v0.1-google-startups-checkpoint` |
| Pitch | `docs/startup/pitch.md` |
| Traction | `docs/startup/traction.md` |
| Roadmap | `docs/startup/roadmap.md` |
| Founder story | `docs/startup/founder-story.md` |

---

## Application Checklist

- [x] Live product website
- [x] Working MVP codebase
- [x] Google Cloud / Firebase architecture
- [x] Gemini AI integration
- [x] Privacy Policy and Terms of Service
- [x] Git checkpoint tagged
- [ ] Product demo video (placeholder on website — record before submission)
- [ ] Google Search Console setup
- [ ] App screenshots on website (placeholders currently)

---

## Appendix: Application Talking Points

Quick-reference answers for reviewer questions and interview conversations. All statements are grounded in the current MVP — no fabricated metrics.

### Why Google Cloud?

Aarogya Vault is **already deployed** on Google Cloud and Firebase — not evaluating a migration.

- **Firebase Auth** — Google Sign-In for patients
- **Cloud Firestore** — Document metadata, OCR results, user profiles, waitlist
- **Cloud Storage** — Per-user medical document files
- **Cloud Functions v2** — Event-driven OCR pipeline on upload
- **Firebase Hosting** — Live website at aarogyavault.live
- **Gemini API** — Medical OCR and summary generation

Choosing Google Cloud was a production decision from day one. Credits extend an existing architecture — they do not fund a platform switch.

### Why Gemini?

Gemini is not an add-on feature — it **is** the comprehension layer of the product.

- **Multimodal input** — Processes the PDFs and images patients actually upload (not just plain text)
- **Single-call extraction + summary** — Returns structured JSON with `extractedText` and `summary`
- **Model in production** — `gemini-2.5-flash`, integrated via `GeminiOcrProvider` in Cloud Functions
- **Purpose-built prompt** — OCR engine prompt tuned for medical documents, not generic chat

Without Gemini, Aarogya Vault is a storage app. With Gemini, it is a document *understanding* platform. The product cannot deliver its core value proposition without it.

### Why now?

The market timing is driven by patient behaviour, not technology hype:

- Patients in India receive more digital medical documents than ever (PDFs, images via WhatsApp and email)
- Digital health adoption is growing, but records remain fragmented across providers
- Patients expect to own and carry their health data — no personal tool exists for this
- AI lowers the comprehension barrier at the moment document volume is accelerating

The need exists independent of AI. AI makes addressing it practical at scale.

### Why are credits required?

The OCR pipeline is **built, deployed, and tested** — but **paused** because Google Cloud and Gemini API credits are exhausted.

- Cloud Functions are deployed (`onDocumentUploaded`)
- Gemini integration is complete (`gemini-2.5-flash`)
- Cost safeguards are active (10 MB limit, MIME whitelist, duplicate skip, no auto-retry)
- The blocker is **operational budget**, not code, architecture, or deployment

Credits are needed to:

1. **Resume OCR processing** for existing and new uploads
2. **Support beta user document volume** during Q3 2026 testing
3. **Keep Firebase services running** at scale beyond free-tier limits

This is a direct, immediate, and verifiable use of credits — not speculative R&D.

### What happens if credits are awarded?

**Immediate (Week 1–2):**

- Resume Gemini OCR processing on the deployed Cloud Function
- Process test documents end-to-end to validate pipeline health
- Record product demo video for website and application reviewers

**Short-term (Month 1–3 — Beta):**

- Onboard waitlist users to the Android app
- Ship in-app OCR summary viewer (UI in active development)
- Collect first traction metrics: uploads, OCR success rate, waitlist growth
- Document findings in `traction.md`

**Medium-term (Month 3–6 — Launch prep):**

- Publish to Google Play Store
- Create production Firebase project separate from dev
- Integrate Firebase Analytics for usage tracking
- Add real app screenshots and Hindi localization to website

**Ongoing:**

- All services remain on Google Cloud — credits fund the infrastructure the product already runs on
- Usage scales with beta adoption, monitored against credit allocation
- Founder reports usage patterns and milestones back through program channels

**If credits are not awarded:** The MVP remains deployed but OCR stays paused. Beta testing and user validation cannot proceed at meaningful scale. The architecture is ready — the constraint is infrastructure budget.
