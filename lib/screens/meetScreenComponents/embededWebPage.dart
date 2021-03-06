import 'package:flutter/material.dart';
import 'package:meeter/utils/appStateNotifier.dart';
import 'package:meeter/utils/authStatusNotifier.dart';
import 'package:provider/provider.dart';
import 'package:webviewx/webviewx.dart';

class WebViewForMeetIntegration extends StatefulWidget {
  final double height;
  final double? width;
  final String subject;

  const WebViewForMeetIntegration(
      {Key? key, required this.height, required this.subject, this.width})
      : super(key: key);

  @override
  _WebViewForMeetIntegrationState createState() =>
      _WebViewForMeetIntegrationState();
}

class _WebViewForMeetIntegrationState extends State<WebViewForMeetIntegration>
    with AutomaticKeepAliveClientMixin<WebViewForMeetIntegration> {
  final String name = 'anonymous';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: WebViewX(
        onWebResourceError: (error) {
          print(error.description);
        },
        initialContent: """
        <!DOCTYPE html>
        <body style="margin: 0;">
            <div id="meet"></div>
            <script src='https://meet.jit.si/external_api.js'></script>
            <script>
                  const domain = 'meet.jit.si';
                  const options = {
                      roomName: '${widget.subject.replaceAll(' ', '')}',
                      userInfo: {
                        displayName: '$name'
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
                      width: '${widget.width ?? '100%'}',
                      height: ${widget.height},
                      parentNode: document.querySelector('#meet')
                  };
                  const api = new JitsiMeetExternalAPI(domain, options);
            </script>
        </body>
        </html>""",
        initialSourceType: SourceType.HTML,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
