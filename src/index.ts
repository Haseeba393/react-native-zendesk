import NativeZendesk, {
  type ZendeskConfig,
  type ZendeskCustomField,
  type ZendeskTicketRequest,
} from './specs/NativeZendesk';
export { ZendeskHelpCenterView } from './ZendeskHelpCenterView';

export async function initializeZendesk(config: ZendeskConfig): Promise<boolean> {
  return NativeZendesk.initialize(config);
}

export async function getZendeskArticles(
  locale?: string,
  labels?: string[],
  page?: number,
  perPage?: number
) {
  return NativeZendesk.getArticles(locale, labels, page, perPage);
}

export async function getZendeskArticle(articleId: number, locale?: string) {
  return NativeZendesk.getArticle(articleId, locale);
}

export async function searchZendeskArticles(
  query: string,
  locale?: string,
  page?: number,
  perPage?: number
) {
  return NativeZendesk.searchArticles(query, locale, page, perPage);
}

export async function createZendeskTicket(request: ZendeskTicketRequest) {
  return NativeZendesk.createTicket(request);
}

export async function openZendeskHelpCenter() {
  return NativeZendesk.openHelpCenter();
}

export async function openZendeskArticle(articleId: number) {
  return NativeZendesk.openArticle(articleId);
}

export async function openZendeskContactSupport() {
  return NativeZendesk.openContactSupport();
}

export async function openZendeskContactSupportWithDetails(
  email: string,
  customFields: ReadonlyArray<ZendeskCustomField>
) {
  return NativeZendesk.openContactSupportWithDetails(email, customFields);
}

export type { ZendeskCustomField };
