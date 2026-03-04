export type ZendeskExampleConfig = {
  subdomain: string;
  zendeskUrl: string;
  appId: string;
  clientId: string;
  name: string;
  email: string;
  apiToken: string;
  locale: string;
  articleId: string;
  query: string;
};

const baseConfig: ZendeskExampleConfig = {
  subdomain: '',
  zendeskUrl: 'https://your-subdomain.zendesk.com',
  appId: '',
  clientId: '',
  name: '',
  email: '',
  apiToken: '',
  locale: 'en-us',
  articleId: '0',
  query: 'refund',
};

let localOverrides: Partial<ZendeskExampleConfig> = {};
try {
  // Optional untracked local config for real credentials.
  const local = require('./zendesk.config.local').default;
  if (local && typeof local === 'object') {
    localOverrides = local as Partial<ZendeskExampleConfig>;
  }
} catch {
  // No local override file found; use base config.
}

const zendeskConfig: ZendeskExampleConfig = {
  ...baseConfig,
  ...localOverrides,
};

export default zendeskConfig;
