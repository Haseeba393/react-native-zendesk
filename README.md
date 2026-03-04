# react-native-zendesk

React Native Zendesk integration with **New Architecture** support (TurboModules + Fabric component). Use official Zendesk Support SDK UIs on iOS and Android.

## Features

- Initialize Zendesk account config from JavaScript
- Initialize official Zendesk Support SDK (Android + iOS) when credentials are provided
- Open Help Center, articles, and contact support in native Zendesk UI (with browser fallback)
- Embed Help Center in your app with `ZendeskHelpCenterView`
- Custom fields support for contact requests

## Requirements

- React Native 0.72+ with **New Architecture** enabled
- iOS 13.0+
- Android minSdkVersion 21+

## Installation

```bash
npm install react-native-zendesk
# or
yarn add react-native-zendesk
```

### iOS

```bash
cd ios && pod install
```

### Android

No additional setup required. Gradle will sync automatically.

## API

```ts
import {
  initializeZendesk,
  getZendeskArticles,
  getZendeskArticle,
  searchZendeskArticles,
  createZendeskTicket,
  openZendeskHelpCenter,
  openZendeskArticle,
  openZendeskContactSupport,
  openZendeskContactSupportWithDetails,
  ZendeskHelpCenterView,
} from 'react-native-zendesk';
```

### Initialize

```ts
await initializeZendesk({
  zendeskUrl: 'https://your-subdomain.zendesk.com', // required for native Zendesk SDK initialization
  appId: 'zendesk_app_id', // required for native Zendesk SDK initialization
  clientId: 'zendesk_client_id', // required for native Zendesk SDK initialization
  // subdomain is optional when zendeskUrl is provided
  // subdomain: 'your-subdomain',
  name: 'John Appleseed', // optional identity
  email: 'agent@example.com', // optional, required for authenticated APIs
  apiToken: 'zendesk_api_token', // optional, required for authenticated APIs
  locale: 'en-us',
});
```

### Open Help Center

```ts
await openZendeskHelpCenter();
```

### Open a specific article

```ts
await openZendeskArticle(12345);
```

### Get articles / Search / Create ticket

`getZendeskArticles`, `searchZendeskArticles`, and `createZendeskTicket` open the native Help Center or Contact Support UI. Use `openZendeskHelpCenter` or `openZendeskContactSupport` directly for the same behavior.

### Open contact support

```ts
await openZendeskContactSupport();
```

### Open contact support with custom fields

Pass custom fields as key-value pairs. The `key` is the Zendesk custom field ID (as string, e.g. `"360035988993"`), and `value` is the field value.

```ts
import {
  openZendeskContactSupportWithDetails,
  type ZendeskCustomField,
} from 'react-native-zendesk';

await openZendeskContactSupportWithDetails('user@example.com', [
  { key: '360035988993', value: '1.0.0' },       // e.g. app version
  { key: '25024443', value: 'Diagnostic info' }, // e.g. diagnostic description
]);
```

### Native Help Center view

```tsx
<ZendeskHelpCenterView
  style={{ flex: 1 }}
  url="https://your-subdomain.zendesk.com/hc/en-us"
  javaScriptEnabled
/>
```

## Behavior Notes

- **New Architecture required**: This package uses TurboModules and Fabric. Ensure `newArchEnabled` is `true` in your React Native config.
- **Native SDK vs browser**: When `zendeskUrl`, `appId`, and `clientId` are set in `initializeZendesk`, the native Zendesk SDK UIs are used. Otherwise, methods fall back to opening Help Center URLs in the browser.
- **Subdomain**: Optional if `zendeskUrl` is provided. It is auto-derived from `https://<subdomain>.zendesk.com`.
- **Custom field IDs**: Find your Zendesk custom field IDs in Admin Center → Objects and rules → Tickets → Fields.

## Example App

An example app is included in `example/` to test this package locally.

```bash
cd example
npm install
cd ios && pod install && cd ..
npm run ios
# or
npm run android
```

Create `example/zendesk.config.local.ts` with your Zendesk credentials for full testing (see `zendesk.config.local.example.ts`).

## Publishing

Before publishing to npm:

1. Add your name/email to `author` in `package.json`.
2. Update the `LICENSE` copyright year and holder if needed.
3. Run `npm pack` to verify the package contents.

### npm

```bash
npm login
npm publish
```

### GitHub

```bash
git init
git add .
git commit -m "Initial release"
git remote add origin https://github.com/Haseeba393/react-native-zendesk.git
git push -u origin main
git tag v0.1.0
git push origin v0.1.0
```

## License

MIT
