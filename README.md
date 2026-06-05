# Aarogya Vault

AI-powered healthcare document vault — securely store, organize, and understand your medical records.

**Website:** [aarogyavault.live](https://aarogyavault.live)  
**Founder:** Amrit Kumar  
**Stage:** Bootstrapped MVP

## Monorepo Structure

```
aarogya-vault/
├── apps/
│   └── mobile_app/     # Flutter mobile app (Riverpod, GoRouter)
├── backend/
│   └── functions/      # Firebase Cloud Functions
├── website/
│   └── public/         # Marketing site (Firebase Hosting)
├── firebase.json       # Firebase project configuration
└── melos.yaml          # Monorepo tooling
```

## Tech Stack

| Layer          | Technology                          |
|----------------|-------------------------------------|
| Mobile         | Flutter, Riverpod, GoRouter         |
| Backend        | Firebase Auth, Firestore, Storage   |
| Serverless     | Firebase Cloud Functions            |
| AI             | Google Gemini API                   |
| Infrastructure | Google Cloud, Firebase              |
| Website        | HTML, CSS, Vanilla JS               |

## Quick Start

### Mobile App

```bash
cd apps/mobile_app
flutter pub get
flutter run
```

### Cloud Functions

```bash
cd backend/functions
npm install
npm run build
```

### Website (Local)

```bash
firebase emulators:start --only hosting
# or
cd website/public && python3 -m http.server 8080
```

### Deploy Website

```bash
firebase deploy --only hosting,firestore:rules
```

See [website/README.md](website/README.md) for full deployment and domain setup instructions.

## Firebase Project

- **Project ID:** `aarogya-vault-dev`
- **Hosting:** `website/public`
- **Functions:** `backend/functions`
- **Firestore Rules:** `apps/mobile_app/firestore.rules`

## License

Proprietary. All rights reserved © Aarogya Vault.
