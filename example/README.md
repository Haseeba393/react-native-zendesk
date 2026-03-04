# Zendesk Example App

This app exercises the local `react-native-zendesk` package end-to-end.

## Install

```sh
npm install
```

For iOS:

```sh
cd ios
bundle install
bundle exec pod install
cd ..
```

## Local config file

You can avoid typing credentials every run by creating a local config:

```sh
cp zendesk.config.local.example.ts zendesk.config.local.ts
```

Then edit `zendesk.config.local.ts` with your Zendesk values.

Minimum required values for SDK initialization:
- `zendeskUrl`
- `appId`
- `clientId`

`subdomain` is optional if `zendeskUrl` is present.

Notes:
- `zendesk.config.local.ts` is gitignored
- base defaults live in `zendesk.config.ts`
- local file overrides base values automatically

## Run

```sh
npm run android
```

or

```sh
npm run ios
```
