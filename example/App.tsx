import React, {useMemo, useState} from 'react';
import {
  Alert,
  Button,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';
import {
  ZendeskHelpCenterView,
  createZendeskTicket,
  getZendeskArticles,
  initializeZendesk,
  openZendeskArticle,
  openZendeskContactSupport,
  openZendeskContactSupportWithDetails,
  openZendeskHelpCenter,
  searchZendeskArticles,
} from 'react-native-zendesk';
import zendeskConfig from './zendesk.config';

function App() {
  const [subdomain, setSubdomain] = useState(zendeskConfig.subdomain);
  const [zendeskUrl, setZendeskUrl] = useState(zendeskConfig.zendeskUrl);
  const [appId, setAppId] = useState(zendeskConfig.appId);
  const [clientId, setClientId] = useState(zendeskConfig.clientId);
  const [name, setName] = useState(zendeskConfig.name);
  const [email, setEmail] = useState(zendeskConfig.email);
  const [apiToken, setApiToken] = useState(zendeskConfig.apiToken);
  const [locale, setLocale] = useState(zendeskConfig.locale);
  const [articleId, setArticleId] = useState(zendeskConfig.articleId);
  const [query, setQuery] = useState(zendeskConfig.query);
  const [logText, setLogText] = useState('Ready');
  const [showEmbedded, setShowEmbedded] = useState(false);

  const resolvedSubdomain = useMemo(() => {
    if (subdomain.trim().length > 0) {
      return subdomain.trim();
    }
    try {
      const host = new URL(zendeskUrl).hostname.toLowerCase();
      if (host.endsWith('.zendesk.com')) {
        return host.replace('.zendesk.com', '');
      }
      return '';
    } catch {
      return '';
    }
  }, [subdomain, zendeskUrl]);

  const helpCenterUrl = useMemo(() => {
    if (resolvedSubdomain.length > 0) {
      return `https://${resolvedSubdomain}.zendesk.com/hc/${locale}`;
    }
    return zendeskUrl;
  }, [locale, resolvedSubdomain, zendeskUrl]);

  const writeLog = (value: unknown) => {
    const next = typeof value === 'string' ? value : JSON.stringify(value, null, 2);
    setLogText(next);
  };

  const onInitialize = async () => {
    try {
      const ok = await initializeZendesk({
        subdomain,
        zendeskUrl,
        appId: appId || undefined,
        clientId: clientId || undefined,
        name: name || undefined,
        email: email || undefined,
        apiToken: apiToken || undefined,
        locale,
      });
      writeLog({event: 'initializeZendesk', ok});
    } catch (error) {
      Alert.alert('Initialize failed', String(error));
    }
  };

  const onGetArticles = async () => {
    try {
      const data = await getZendeskArticles(locale, [], 1, 10);
      writeLog(data);
    } catch (error) {
      Alert.alert('Get articles failed', String(error));
    }
  };

  const onSearch = async () => {
    try {
      const data = await searchZendeskArticles(query, locale, 1, 10);
      writeLog(data);
    } catch (error) {
      Alert.alert('Search failed', String(error));
    }
  };

  const onCreateTicket = async () => {
    try {
      const data = await createZendeskTicket({
        subject: 'Test ticket from RN example app',
        description: 'This ticket was created from the local example app.',
        requesterEmail: email || undefined,
        requesterName: 'RN Example',
        tags: ['rn', 'example'],
      });
      writeLog(data);
    } catch (error) {
      Alert.alert('Create ticket failed', String(error));
    }
  };

  const parsedArticleId = Number(articleId) || 0;

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" />
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Zendesk Package Example</Text>
        <Text style={styles.subtitle}>
          Use this screen to validate native SDK init and API methods.
        </Text>

        <Field
          label="Subdomain (optional if Zendesk URL is set)"
          value={subdomain}
          onChangeText={setSubdomain}
        />
        <Field label="Zendesk URL" value={zendeskUrl} onChangeText={setZendeskUrl} />
        <Field label="App ID" value={appId} onChangeText={setAppId} />
        <Field label="Client ID" value={clientId} onChangeText={setClientId} />
        <Field label="Name (optional)" value={name} onChangeText={setName} />
        <Field label="Email (optional)" value={email} onChangeText={setEmail} />
        <Field label="API Token (optional)" value={apiToken} onChangeText={setApiToken} />
        <Field label="Locale" value={locale} onChangeText={setLocale} />
        <Field label="Article ID" value={articleId} onChangeText={setArticleId} />
        <Field label="Search Query" value={query} onChangeText={setQuery} />

        <View style={styles.buttonGroup}>
          <Button title="1) Initialize Zendesk" onPress={onInitialize} />
        </View>
        <View style={styles.buttonGroup}>
          <Button title="2) Get Articles" onPress={onGetArticles} />
        </View>
        <View style={styles.buttonGroup}>
          <Button title="3) Search Articles" onPress={onSearch} />
        </View>
        <View style={styles.buttonGroup}>
          <Button title="4) Open Native Help Center" onPress={() => openZendeskHelpCenter()} />
        </View>
        <View style={styles.buttonGroup}>
          <Button
            title="5) Open Native Article"
            onPress={() => openZendeskArticle(parsedArticleId)}
          />
        </View>
        <View style={styles.buttonGroup}>
          <Button title="6) Open Contact Support" onPress={() => openZendeskContactSupport()} />
        </View>
        <View style={styles.buttonGroup}>
          <Button
            title="7) Contact Support with Custom Fields"
            onPress={() =>
              openZendeskContactSupportWithDetails(email || 'user@example.com', [
                {key: '360035988993', value: '1.0.0'},
                {key: '25024443', value: 'Diagnostic info from app'},
              ])
            }
          />
        </View>
        <View style={styles.buttonGroup}>
          <Button title="8) Create Ticket" onPress={onCreateTicket} />
        </View>
        <View style={styles.buttonGroup}>
          <Button
            title={showEmbedded ? 'Hide Embedded Help Center' : 'Show Embedded Help Center'}
            onPress={() => setShowEmbedded(prev => !prev)}
          />
        </View>

        {showEmbedded ? (
          <View style={styles.embeddedWrap}>
            <ZendeskHelpCenterView
              style={styles.embedded}
              url={helpCenterUrl}
              javaScriptEnabled
            />
          </View>
        ) : null}

        <Text style={styles.logLabel}>Result</Text>
        <Text selectable style={styles.logText}>
          {logText}
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

type FieldProps = {
  label: string;
  value: string;
  onChangeText: (value: string) => void;
};

function Field({label, value, onChangeText}: FieldProps) {
  return (
    <View style={styles.fieldWrap}>
      <Text style={styles.label}>{label}</Text>
      <TextInput
        autoCapitalize="none"
        autoCorrect={false}
        style={styles.input}
        value={value}
        onChangeText={onChangeText}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  safeArea: {flex: 1, backgroundColor: '#f7f8fa'},
  content: {padding: 16, paddingBottom: 28},
  title: {fontSize: 22, fontWeight: '700', color: '#101828'},
  subtitle: {marginTop: 6, marginBottom: 16, color: '#475467'},
  fieldWrap: {marginBottom: 10},
  label: {fontSize: 12, color: '#344054', marginBottom: 4},
  input: {
    borderWidth: 1,
    borderColor: '#d0d5dd',
    borderRadius: 8,
    backgroundColor: '#fff',
    paddingHorizontal: 10,
    paddingVertical: 8,
    color: '#111827',
  },
  buttonGroup: {marginTop: 8},
  logLabel: {marginTop: 18, marginBottom: 6, fontWeight: '600', color: '#101828'},
  logText: {
    borderWidth: 1,
    borderColor: '#d0d5dd',
    borderRadius: 8,
    padding: 10,
    backgroundColor: '#fff',
    color: '#0f172a',
    minHeight: 120,
  },
  embeddedWrap: {
    marginTop: 12,
    borderWidth: 1,
    borderColor: '#d0d5dd',
    borderRadius: 8,
    overflow: 'hidden',
  },
  embedded: {
    height: 360,
    width: '100%',
  },
});

export default App;
