import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';

class WebViewForMeetIntegration extends StatelessWidget {
  const WebViewForMeetIntegration({
    Key? key,
    required this.subject,
    required this.nameText,
    required this.height,
  }) : super(key: key);

  final TextEditingController nameText;
  final double height;
  final String subject;

  @override
  Widget build(BuildContext context) {
    return WebViewX(
      onWebResourceError: (error) {
        print(error.toString());
      },
      initialContent: """
    <!DOCTYPE html>
    <body style="margin: 0;">
        <div id="meet"></div>
        <script src='https://meet.jit.si/external_api.js'></script>
        <script>
              const domain = 'meet.jit.si';
              const options = {
                  roomName: '${subject.replaceAll(' ', '')}',
                  userInfo: {
                    displayName: '${nameText.text}'
                  },
                  configOverwrite: {
                    requireDisplayName: false,
                    enableWelcomePage: false,
                    toolbarButtons: [
       'microphone', 'camera', 'desktop', 'fullscreen', 'hangup', 'raisehand',
       
       'tileview'
    ],
                     startWithAudioMuted: true },
                  interfaceConfigOverwrite: { 
                      SHOW_CHROME_EXTENSION_BANNER: false,

    SHOW_DEEP_LINKING_IMAGE: false,
    SHOW_JITSI_WATERMARK: false,
    SHOW_POWERED_BY: false,
    SHOW_PROMOTIONAL_CLOSE_PAGE: false,
                    DISABLE_DOMINANT_SPEAKER_INDICATOR: true },
                  width: '100%',
                  height: $height,
                  parentNode: document.querySelector('#meet')
              };
              const api = new JitsiMeetExternalAPI(domain, options);
        </script>
    </body>
    </html>""",
      initialSourceType: SourceType.HTML,
    );
  }
}
