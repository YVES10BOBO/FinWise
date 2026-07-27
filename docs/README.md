# FinWise — Documentation

Supporting documentation for the FinWise app. The main project overview and
architecture notes live in the [root README](../README.md).

---

## Publishing

| Document | Purpose |
|---|---|
| `PRE_LAUNCH_CHECKLIST.md` | Everything to verify before a Play Store release |
| `FIREBASE_SETUP_AND_SECURITY.md` | Firestore rules, password reset, security verification |
| `PLAY_STORE_LISTING_CONTENT.md` | Store description, keywords, listing copy |
| `PLAY_STORE_ASSETS_REQUIREMENTS.md` | Screenshot sizes, graphics specifications |

## Legal pages (served via GitHub Pages)

| File | Purpose |
|---|---|
| `index.html` | Landing page |
| `PRIVACY_POLICY.html` | Privacy policy — **required public URL for Play Store** |
| `delete-account.html` | Account deletion instructions — required by Play Store |

To publish these: repository **Settings → Pages → Source: main branch, /docs
folder**. They become available at:

```
https://<username>.github.io/<repo>/PRIVACY_POLICY.html
```

Keep the hosted privacy policy **identical** to the in-app version
(Settings → Privacy Policy). A mismatch between the two, or between either and
the Play Data Safety form, is a common cause of rejection.

---

## Notes on older documents

Several earlier planning files overlapped (`READY_TO_PUBLISH`,
`READY_FOR_PLAY_STORE`, `PUBLISH_TO_PLAY_STORE`, `NEXT_STEPS_AFTER_GITHUB`,
`BUILD_AND_PUBLISH`, `FINAL_PUBLISHING_CHECKLIST`). They have been superseded
by `PRE_LAUNCH_CHECKLIST.md` and can be deleted.
