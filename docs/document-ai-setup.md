# Document AI Setup — Aarogya Vault

Aarogya Vault uses **Enterprise Document OCR** for production OCR. Do **not** create the basic **OCR Processor** — it lacks handwriting detection, font style analysis, and the confidence signals the pipeline relies on.

## Prerequisites

- GCP project: `aarogya-vault-dev` (or your Firebase project ID)
- `gcloud` CLI authenticated with project admin access
- Firebase Cloud Functions runtime service account

## 1. Enable the Document AI API

```bash
gcloud services enable documentai.googleapis.com \
  --project=aarogya-vault-dev
```

## 2. Create an Enterprise Document OCR Processor

### Console (recommended)

1. Open [Document AI Console](https://console.cloud.google.com/ai/document-ai/processors)
2. Select region: **US** or **EU** (must match `DOCUMENT_AI_LOCATION`)
3. Click **Create Processor**
4. Choose processor type: **Enterprise Document OCR**
   - **NOT** "OCR Processor" / "Document OCR" (basic)
5. Name it (e.g. `aarogya-vault-enterprise-ocr`)
6. Copy the **Processor ID** from the processor details page

### gcloud (alternative)

List available processor types to confirm Enterprise OCR is available in your region:

```bash
gcloud ai document-processors processor-types list \
  --location=us \
  --project=aarogya-vault-dev
```

Look for type `Document OCR`, then create:

```bash
gcloud ai document-processors processors create \
  --location=us \
  --display-name="aarogya-vault-enterprise-ocr" \
  --type=Document OCR \
  --project=aarogya-vault-dev
```

## 3. Save the Processor ID

Note the processor ID (final path segment), e.g.:

```
projects/aarogya-vault-dev/locations/us/processors/abc123def456
                                                      ^^^^^^^^^^^^
                                                      processor ID
```

## 4. Environment Variables

Add to `backend/functions/.env` (loaded automatically on deploy):

```bash
USE_DOCUMENT_AI_OCR=true
DOCUMENT_AI_PROJECT_ID=aarogya-vault-dev
DOCUMENT_AI_LOCATION=us
DOCUMENT_AI_PROCESSOR_ID=<your-processor-id>
```

The Cloud Function validates at startup that the processor type is `Document OCR`. Deploying with a basic `OCR_PROCESSOR` fails immediately with a descriptive error.

## 5. IAM Permissions

Grant the Cloud Functions runtime service account Document AI access:

```bash
gcloud projects add-iam-policy-binding aarogya-vault-dev \
  --member="serviceAccount:aarogya-vault-dev@appspot.gserviceaccount.com" \
  --role="roles/documentai.apiUser"
```

The function also writes OCR text to Storage (`ocr-results/{documentId}/full_text.txt`). The default App Engine / Functions service account already has Storage access in Firebase projects. No extra Storage role is typically needed.

## 6. Deploy

```bash
cd backend/functions
npm run build && npm test
firebase deploy --only functions:onDocumentUploaded
```

## 7. Rollback

Set `USE_DOCUMENT_AI_OCR=false` in `.env` and redeploy. The legacy Gemini OCR path is unchanged.

## Enterprise OCR Capabilities Used

| Feature | Used for |
|---|---|
| Printed text extraction | Lab reports, discharge summaries |
| Handwriting detection | Prescription classification |
| Per-token confidence | `ocrConfidence` in Firestore |
| Layout detection | Page count, structure metadata |
| Font style detection | Handwriting vs printed signals |

## Troubleshooting

| Error | Fix |
|---|---|
| `Invalid Document AI processor. Expected: Enterprise Document OCR` | Delete basic OCR processor; create Enterprise Document OCR |
| `DOCUMENT_AI_PROCESSOR_ID is not configured` | Set processor ID in `.env` |
| `PERMISSION_DENIED` on `processDocument` | Add `roles/documentai.apiUser` to service account |
| `OCR text not found in storage` | v2 record exists but Storage object missing — re-process document |
