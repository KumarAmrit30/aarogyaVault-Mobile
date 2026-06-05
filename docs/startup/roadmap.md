# Roadmap — Aarogya Vault

**Last updated:** June 2026  
**Current stage:** Phase 1 complete (MVP)  
**Git checkpoint:** `v0.1-google-startups-checkpoint`

---

## Overview

| Phase | Name | Status | Timeline |
|-------|------|--------|----------|
| 1 | MVP | ✅ Completed | 2025 – June 2026 |
| 2 | Beta Testing | 🔜 Next | Q3 2026 |
| 3 | Public Launch | 📋 Planned | Q4 2026 |
| 4 | AI Healthcare Assistant | 📋 Planned | 2027 |
| 5 | Healthcare Ecosystem Platform | 📋 Planned | 2028+ |

---

## Phase 1: MVP (Completed)

**Goal:** Prove the core loop — upload a medical document, process it with Gemini OCR, store results, and access them securely.

### Deliverables (All Complete)

- [x] Flutter Android app with Riverpod + GoRouter
- [x] Google Sign-In via Firebase Authentication
- [x] User profile creation in Firestore
- [x] Document upload (PDF, JPEG, PNG — max 10 MB)
- [x] Seven document type categories
- [x] Firebase Cloud Storage integration
- [x] Firestore document metadata and security rules
- [x] Cloud Function `onDocumentUploaded` (Storage v2 trigger)
- [x] Gemini 2.5 Flash medical OCR + summary generation
- [x] OCR results stored in Firestore (`ocr_results`)
- [x] Duplicate OCR protection
- [x] MIME whitelist and file size validation
- [x] OCR retrieval data layer in Flutter
- [x] Production website at aarogyavault.live
- [x] Waitlist with Firestore integration
- [x] Privacy Policy and Terms of Service
- [x] Git checkpoint tagged for application review

### Measurable Outcomes

| Metric | Result |
|--------|--------|
| Core features shipped | 15+ |
| Google Cloud services in use | 6 (Auth, Firestore, Storage, Functions, Hosting, Gemini) |
| End-to-end pipeline | Upload → Storage → Function → Gemini → Firestore |
| Repository tags | 5 milestone tags |

### Known Gaps at MVP Exit

- In-app OCR summary viewer UI not yet shipped
- OCR paused due to exhausted cloud credits
- No Google Play listing
- No Firebase Analytics instrumentation
- Demo video placeholder on website

---

## Phase 2: Beta Testing

**Goal:** Validate product with real users and real medical documents. Refine OCR accuracy, UX, and reliability.

**Timeline:** Q3 2026 (July – September 2026)

### Key Initiatives

1. **Resume OCR pipeline** — Apply Google Cloud credits to unblock Gemini processing
2. **Ship in-app summary viewer** — Document detail screen displaying `extractedText` and `summary`
3. **Onboard beta cohort** — Invite users from waitlist (target: TBD)
4. **Record product demo** — Replace website video placeholder
5. **Add real app screenshots** — Replace phone mockup placeholders on website
6. **Integrate Firebase Analytics** — Begin tracking usage metrics
7. **OCR quality review** — Test across prescription, lab report, and discharge summary formats

### Measurable Milestones

| Milestone | Target | Measurement |
|-----------|--------|-------------|
| Beta users onboarded | TBD | Firebase Auth user count |
| Documents uploaded (beta) | TBD | Firestore `documents` count |
| OCR success rate | >90% | `ocr_results` / uploads ratio |
| In-app summary viewer shipped | ✅ by end of Q3 | Feature release |
| Demo video published | ✅ by end of Q3 | Website `#demo` section |
| Waitlist signups | TBD | Firestore `waitlist` count |

### Exit Criteria for Phase 2

- [ ] 10+ beta users with uploaded documents (target — to be confirmed)
- [ ] OCR pipeline running reliably on cloud credits
- [ ] In-app summary viewer live
- [ ] No critical bugs in upload or auth flow
- [ ] First traction metrics documented in `traction.md`

---

## Phase 3: Public Launch

**Goal:** Release on Google Play and open to general users in India.

**Timeline:** Q4 2026 (October – December 2026)

### Key Initiatives

1. **Google Play Store listing** — App publishing with screenshots, description, privacy policy link
2. **Production Firebase project** — Separate `aarogya-vault-prod` from dev environment
3. **Smart search** — Search documents by name, type, and OCR-extracted content
4. **Performance optimization** — Upload speed, OCR latency, app startup time
5. **Hindi localization** — UI strings for Indian market (i18n)
6. **Google Search Console** — Submit sitemap, monitor SEO
7. **Waitlist → user conversion** — Email notification flow for launch

### Measurable Milestones

| Milestone | Target | Measurement |
|-----------|--------|-------------|
| Google Play release | ✅ by end of Q4 | Play Store listing live |
| Monthly active users | TBD | Firebase Analytics |
| Documents processed (monthly) | TBD | Firestore + Functions logs |
| App store rating | TBD | Google Play Console |
| Website organic traffic | TBD | Search Console / Analytics |

### Exit Criteria for Phase 3

- [ ] Public app available on Google Play
- [ ] Production infrastructure separated from dev
- [ ] Smart search shipped
- [ ] First month of public usage metrics collected

---

## Phase 4: AI Healthcare Assistant

**Goal:** Move beyond single-document summaries to cross-document intelligence and patient-friendly health insights.

**Timeline:** 2027

### Planned Capabilities

1. **Health Timeline** — Chronological view of all uploaded documents
2. **Trend analysis** — Track lab values across multiple reports (e.g., HbA1c over time)
3. **Cross-document summaries** — "Your health story" generated from full document history
4. **Proactive alerts** — Flag out-of-range values or follow-up reminders (informational only)
5. **Family vault foundations** — Begin multi-profile architecture

### Measurable Milestones

| Milestone | Target | Measurement |
|-----------|--------|-------------|
| Health Timeline feature shipped | Q1 2027 | Feature release |
| Users with 5+ documents | TBD | Firestore aggregation |
| Cross-document AI summaries | Q2 2027 | Feature release |
| Family vault beta | Q3 2027 | Feature release |

### Technical Requirements

- Enhanced Firestore data model for temporal queries
- Additional Gemini prompts for multi-document analysis
- Increased Cloud Functions compute (credit-dependent)
- Potential Cloud Run for longer AI workloads

---

## Phase 5: Healthcare Ecosystem Platform

**Goal:** Connect Aarogya Vault with external healthcare providers — labs, hospitals, diagnostic chains.

**Timeline:** 2028+

### Planned Capabilities

1. **Lab report auto-import** — API integrations with diagnostic providers
2. **Hospital discharge integration** — Structured document ingestion
3. **ABDM / health stack alignment** — Explore India health ID ecosystem compatibility
4. **Provider dashboard** — B2B tools for clinics and labs (if validated)
5. **Enterprise security tier** — Enhanced controls for family and corporate use

### Measurable Milestones

| Milestone | Target | Measurement |
|-----------|--------|-------------|
| First lab integration pilot | TBD | Partnership + API live |
| Documents auto-imported (monthly) | TBD | Integration logs |
| B2B pilot partners | TBD | Signed agreements |

*Note: Phase 5 partnerships and integrations are aspirational. No partnerships exist today.*

---

## Dependency Map

```
Phase 1 (MVP) ──requires──▶ Google Cloud credits (blocked)
       │
       ▼
Phase 2 (Beta) ──requires──▶ OCR running + summary viewer + beta users
       │
       ▼
Phase 3 (Launch) ──requires──▶ Play Store approval + production infra
       │
       ▼
Phase 4 (AI Assistant) ──requires──▶ Sufficient document volume + AI compute
       │
       ▼
Phase 5 (Ecosystem) ──requires──▶ User base + provider partnerships
```

---

## Immediate Priority

**Unblock Phase 2 by securing Google for Startups Cloud credits.**

This is the single highest-leverage action: it resumes the Gemini OCR pipeline, enables beta testing, and provides the first real user validation data for all subsequent phases.
