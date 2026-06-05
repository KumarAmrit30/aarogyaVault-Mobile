import * as admin from "firebase-admin";

admin.initializeApp();

export {onDocumentUploaded} from "./triggers/document_uploaded";
