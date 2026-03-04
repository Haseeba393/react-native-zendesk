import React from 'react';
import type { StyleProp, ViewStyle } from 'react-native';
import NativeComponent, {
  type ZendeskHelpCenterViewProps,
} from './fabric/ZendeskHelpCenterViewNativeComponent';

type Props = Omit<ZendeskHelpCenterViewProps, 'style'> & {
  style?: StyleProp<ViewStyle>;
};

export function ZendeskHelpCenterView(props: Props) {
  return <NativeComponent {...props} />;
}
