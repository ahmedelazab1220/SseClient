import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert'; // For utf8 decoder
import 'dart:typed_data'; // For Uint8List

part 'sse_state.dart';

class SseCubit extends Cubit<SseState> {
  final Dio _dio;

  SseCubit(this._dio) : super(SseInitial());

  Future<void> startSse(String endpoint) async {
    emit(SseLoading());

    try {
      final response = await _dio.get<ResponseBody>(
        endpoint,
        options: Options(responseType: ResponseType.stream),
      );

      // Create a StreamTransformer to decode the Uint8List into a String
      final transformer = StreamTransformer<Uint8List, String>.fromHandlers(
        handleData: (Uint8List data, EventSink<String> sink) {
          sink.add(utf8.decode(data));
        },
      );

      // Apply the transformer to the stream
      final stream = response.data!.stream.transform(transformer);

      stream.listen(
        (event) {
          emit(SseLoaded(event));
        },
        onError: (error) {
          emit(SseError('Error loading SSE: $error'));
        },
        cancelOnError: true,
        onDone: () {
          emit(SseComplete());
        },
      );
    } catch (e) {
      emit(SseError('Failed to connect: $e'));
    }
  }
}
