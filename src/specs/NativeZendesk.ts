import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export type ZendeskConfig = {
  subdomain?: string;
  zendeskUrl?: string;
  appId?: string;
  clientId?: string;
  name?: string;
  email?: string;
  apiToken?: string;
  locale?: string;
};

export type ZendeskTicketRequest = {
  subject: string;
  description: string;
  requesterName?: string;
  requesterEmail?: string;
  tags?: string[];
};

export type ZendeskCustomField = {
  key: string;
  value: string;
};

export interface Spec extends TurboModule {
  initialize(config: ZendeskConfig): Promise<boolean>;
  getArticles(
    locale?: string,
    labels?: string[],
    page?: number,
    perPage?: number
  ): Promise<Record<string, unknown>>;
  getArticle(articleId: number, locale?: string): Promise<Record<string, unknown>>;
  searchArticles(
    query: string,
    locale?: string,
    page?: number,
    perPage?: number
  ): Promise<Record<string, unknown>>;
  createTicket(request: ZendeskTicketRequest): Promise<Record<string, unknown>>;
  openHelpCenter(): Promise<boolean>;
  openArticle(articleId: number): Promise<boolean>;
  openContactSupport(): Promise<boolean>;
  openContactSupportWithDetails(
    email: string,
    customFields: ReadonlyArray<ZendeskCustomField>
  ): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNZendesk');
