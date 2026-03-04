import type { HostComponent, ViewProps } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { WithDefault } from 'react-native/Libraries/Types/CodegenTypes';

export interface ZendeskHelpCenterViewProps extends ViewProps {
  url?: string;
  originWhitelist?: ReadonlyArray<string>;
  javaScriptEnabled?: WithDefault<boolean, true>;
}

export default codegenNativeComponent<ZendeskHelpCenterViewProps>(
  'RNZendeskHelpCenterView'
) as HostComponent<ZendeskHelpCenterViewProps>;
