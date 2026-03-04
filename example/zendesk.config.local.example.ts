import type {ZendeskExampleConfig} from './zendesk.config';

const localZendeskConfig: Partial<ZendeskExampleConfig> = {
  subdomain: '',
  zendeskUrl: 'https://acme.zendesk.com',
  appId: 'your_app_id',
  clientId: 'your_client_id',
  name: 'RN Tester',
  email: 'tester@example.com',
  apiToken: 'your_api_token',
  locale: 'en-us',
  articleId: '123456789',
  query: 'billing',
};

export default localZendeskConfig;
