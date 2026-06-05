/**
 * Waitlist form handler — stores submissions in Firestore `waitlist` collection.
 *
 * Firestore document schema:
 * {
 *   name: string,
 *   email: string,
 *   createdAt: Timestamp,
 *   source: "website"
 * }
 *
 * Requires Firestore rules allowing create on /waitlist/{docId}.
 * See apps/mobile_app/firestore.rules and website/README.md.
 */
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.14.1/firebase-app.js";
import {
  getFirestore,
  collection,
  addDoc,
  serverTimestamp,
} from "https://www.gstatic.com/firebasejs/10.14.1/firebase-firestore.js";
import { firebaseConfig } from "./firebase-config.js";

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const form = document.getElementById("waitlist-form");
const messageEl = document.getElementById("form-message");
const submitBtn = document.getElementById("waitlist-submit");

function showMessage(text, type) {
  if (!messageEl) return;
  messageEl.textContent = text;
  messageEl.className = `form-message ${type}`;
  messageEl.setAttribute("role", "alert");
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

if (form) {
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const nameInput = form.querySelector("#name");
    const emailInput = form.querySelector("#email");
    const name = nameInput.value.trim();
    const email = emailInput.value.trim().toLowerCase();

    if (!name || name.length < 2) {
      showMessage("Please enter your name.", "error");
      nameInput.focus();
      return;
    }

    if (!validateEmail(email)) {
      showMessage("Please enter a valid email address.", "error");
      emailInput.focus();
      return;
    }

    submitBtn.disabled = true;
    submitBtn.textContent = "Joining…";
    messageEl.className = "form-message";

    try {
      await addDoc(collection(db, "waitlist"), {
        name,
        email,
        createdAt: serverTimestamp(),
        source: "website",
      });

      showMessage(
        "You're on the list! We'll be in touch when Aarogya Vault launches.",
        "success"
      );
      form.reset();
    } catch (err) {
      console.error("Waitlist submission failed:", err);
      showMessage(
        "Something went wrong. Please try again or email hello@aarogyavault.live.",
        "error"
      );
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = "Join Waitlist";
    }
  });
}
