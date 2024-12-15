import 'dart:async';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

Future<void> connect() async {
  const hostOptions = PusherChannelsOptions.fromHost(
    scheme: 'ws',
    host: '192.168.1.2',
    key: '<YOUR REVERB KEY>',
    shouldSupplyMetadataQueries: true,
    metadata: PusherChannelsOptionsMetadata.byDefault(),
    port: 8080,
  );

  final client = PusherChannelsClient.websocket(
      options: hostOptions,
      connectionErrorHandler: (exception, trace, refresh) {
        refresh();
      });

  final channel = client.publicChannel(
    'user.5.wallet',
  );

  final private = client.privateChannel(
    'private-App.Models.User.5',
    authorizationDelegate:
        EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
      authorizationEndpoint: Uri.parse('http://192.168.1.2:8000/api/broadcasting/auth'),
      headers: const {
        'Authorization': 'Bearer <USER SANCTUM TOKEN>',
      },
    ),
  );

  StreamSubscription<ChannelReadEvent> channelSubscription =
      channel.bind('App\\Events\\WalletUpdatedEvent').listen((event) {
    print('Event received: ${event.data}');
  });

  StreamSubscription<ChannelReadEvent> privateSubscription =
      private.bind('App\\Events\\WalletUpdatedEvent').listen((event) {
    print('Private event received: ${event.data}');
  });

  client.onConnectionEstablished.listen((s) {
    print('Connection established');
    channel.subscribe();
    private.subscribe();
  });

  await client.connect();
}