import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:sseclient/cubit/sse_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SSE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => SseCubit(Dio()),
        child: const SseScreen(),
      ),
    );
  }
}

class SseScreen extends StatelessWidget {
  const SseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SseCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live SSE Stream'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              cubit.startSse('http://10.0.2.2:8080/api/v1/sse-event');
            },
          ),
        ],
      ),
      body: BlocBuilder<SseCubit, SseState>(
        builder: (context, state) {
          if (state is SseLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SseLoaded) {
            return EventList(event: state.event);
          } else if (state is SseError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            );
          } else if (state is SseComplete) {
            return const Center(
              child: Text(
                'Stream Complete',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            );
          } else {
            return const Center(
              child: Text('Press the refresh button to start the stream.'),
            );
          }
        },
      ),
    );
  }
}

class EventList extends StatefulWidget {
  final String event;

  // ignore: use_super_parameters
  const EventList({Key? key, required this.event}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant EventList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event != widget.event) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 8.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Event Received:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.event,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
