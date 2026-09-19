# Privacy Policy

_Effective 15 September 2026._

This policy covers the QR Scanner + Generator app for Android ("the app"). <!-- Draft written from docs/PRODUCT_RULES.md before the first build. Set the effective date when the closed-test build ships, and update this page in the same PR as any change to what the app stores, shares, or requests (RUN-2, PRIV-6). -->

## Summary

- There's no account. Your scans, the codes you create, and your history stay on your device.
- Nothing you scan or create is sent to us. We don't run servers for the app.
- The app shows ads from Google AdMob, but never on the scanner, on a scan result, or while you create a code. Where the law requires it, you're asked for consent first, and you can change your choice at any time in Settings → Privacy options.
- Crash reports are sent only if you turn them on.
- Buying Pro removes ads. Google Play handles the payment.

## Information stored on your device

- **History:** the decoded content of codes you scan (text, links, Wi-Fi network details including passwords, contact and event details), the codes you create with their style, dates, and the favourites and notes you add. Wi-Fi passwords stay hidden until you tap to reveal them.
- **Trash:** items you delete stay in Trash for 30 days, then the app removes them.
- **Settings:** theme, language, sound and vibration, search engine, whether history is saved, whether crash reports are sent, your consent choices, and whether you own Pro.
- **Never stored:** the camera image, or the photo you scanned a code from. The app keeps only the decoded content.

You can turn off saving history in Settings. Uninstalling the app removes everything it stored on your device.

## Information that leaves your device

- **When you share or export:** a code image, a text, or a CSV file of your history goes only to the app or place you pick. CSV files and shared text hide Wi-Fi passwords unless you choose to include them.
- **When you back up:** the backup file contains your whole history, including Wi-Fi passwords, and goes only where you save or share it. Keep it somewhere safe.
- **When you open something:** opening a link hands it to your browser. "Search the web" sends a scanned product number to the search engine you picked in Settings. Calling, messaging, emailing, saving a contact or event, opening a map, and sending feedback hand the details to the app you use for that.
- **"Check where this link goes," only when you tap it:** the app contacts the link's server, and each server it redirects to, to find the final address. Those servers see the link and your device's IP address. Nothing is sent to us.
- **Ads:** Google AdMob and Google's consent tool collect and share information such as your IP address, device and advertising identifiers, ad interactions, and diagnostics, to show and measure ads. Personalised ads appear only with consent where it's required. See [how Google uses information from apps that use its services](https://policies.google.com/technologies/partner-sites).
- **Crash reports, only if you turn on "Send crash reports":** Firebase Crashlytics receives crash details (what failed in the code, device model, Android version, app version, and an installation identifier). We never add your scans, codes, or history to crash reports.
- **Purchases:** Google Play processes the Pro purchase. The app receives only confirmation that the purchase is valid, never your payment details.
- **Code reading:** codes are read on your phone by Google's ML Kit, which runs entirely on the device. ML Kit sends Google usage and performance statistics about the reader itself (such as how long a read took and the device model). It never sends the camera image, the photo, or what a code contains. See [ML Kit's terms](https://developers.google.com/ml-kit/terms).

The app contains no other analytics.

## Permissions

- **Camera:** to scan codes. It's requested the first time you tap "Allow camera". If you refuse, you can still scan a code from a photo or type it in.
- **Internet and network state:** for ads, consent, purchases, crash reports (if on), the link check (when you tap it), and ML Kit's usage statistics.
- **Google Play billing:** to buy Pro.
- **Advertising ID:** used by the ads SDK. You can reset or delete it in Android's settings.
- **Ad topics and ad measurement (Android's Privacy Sandbox):** the ads SDK may use them to choose and measure ads. You can turn them off in Android's settings.
- **Background tasks:** the ads SDK uses Android's background-task library, which declares that it may keep the device awake briefly and run a foreground service. The app doesn't scan, read codes, or track you in the background.

The app doesn't ask for permission to read your photos: Android's photo picker gives it only the photo you choose. It doesn't ask for contacts, calendar, location, or storage permissions: saving a contact or an event hands it to your contacts or calendar app, and saving a file goes through Android's file picker. <!-- Add Wi-Fi permissions here in the PR that ships joining a scanned network (RES-5). The share target (ENTRY-2) ships only without storage or media permissions (S12); if that ever changes, fix the photo sentence above. -->

## Deleting your information

- Delete items in History (they move to Trash for 30 days), or delete them forever from Trash.
- Turn off saving history in Settings, or clear the app's data or uninstall it to remove everything. Files you exported or backed up stay where you saved them.
- Change your ad consent in Settings → Privacy options, turn off crash reports in Settings, and reset your advertising ID in Android's settings.

## Children

The app isn't directed at children under 13, and we don't knowingly collect information from them.

## Changes to this policy

Changes are published on this page with a new effective date.

## Contact

Questions: open an issue at https://github.com/Oasis-Forge/qr-scanner-generator/issues.
