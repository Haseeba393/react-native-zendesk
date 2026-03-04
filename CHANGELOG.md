# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-02-26

### Added

- Initial release
- React Native New Architecture support (TurboModules + Fabric)
- Zendesk Support SDK integration for iOS and Android
- `initializeZendesk` – configure Zendesk account and SDK
- `openZendeskHelpCenter` – open Help Center in native UI or browser
- `openZendeskArticle` – open a specific article
- `openZendeskContactSupport` – open contact support form
- `openZendeskContactSupportWithDetails` – contact support with custom fields
- `getZendeskArticles`, `searchZendeskArticles`, `createZendeskTicket` – convenience methods (open native UI)
- `ZendeskHelpCenterView` – embed Help Center in app via WebView
