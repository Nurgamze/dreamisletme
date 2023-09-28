import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_keys.dart';
import '../models/base_data_model.dart';
import '../models/base_response_model.dart';


class APIService {
  static Dio? _dio;


  static initialize(String apiBaseURL) async {

 _dio = Dio(BaseOptions(baseUrl: apiBaseURL, connectTimeout: Duration(milliseconds: 30000),receiveTimeout: Duration(milliseconds: 30000),headers: {"Content-Type": "application/json", "apikey": apiKey}));
  }


  ///example: APIService.fetchDataWithModel<ReturnModel,ParseModel>
  static Future<ResponseModel<R>> fetchDataWithModel<R,T extends BaseDataModel>(String url,dynamic postData,T model,{String? partOfJson}) async {
    try{
      var response = await _dio!.post(url,data: postData);

      if(response.statusCode == HttpStatus.ok){

        var responseBody = response.data;
        if(partOfJson != null){
          responseBody = response.data[partOfJson];
        }
        if(responseBody is List){
          return ResponseModel<R>(
              responseData: List<T>.from(responseBody.map((x) => model.fromMap(x))) as R,
              statusCode: 200
          );
        }else if(response is Map) {

          return ResponseModel<R>(

              responseData: model.fromMap(responseBody) as R,
              statusCode: 200
          );
        }

        return ResponseModel<R>(
            responseData: model.fromMap(responseBody) as R,
            statusCode: 200
        );
      }
    } on SocketException {
      return ResponseModel<R>(
          errorMessage: "No internet connection",
          statusCode: 400
      );
    } on HttpException {
      return ResponseModel<R>(
          errorMessage: "Invalid response",
          statusCode: 400
      );
    } on FormatException {
      return ResponseModel<R>(
          errorMessage: "Invalid format",
          statusCode: 400
      );
    }on TimeoutException {
      return ResponseModel<R>(
          errorMessage: "Timeout",
          statusCode: 400
      );
    } on DioError catch(error) {
      var errorResponseData = error.response?.data;
      if(errorResponseData['errorMessage'] != null){
        return ResponseModel<R>(
            errorMessage: errorResponseData['errorMessage'].toString(),
            statusCode: int.tryParse(errorResponseData['statusCode'].toString()) ?? 400
        );
      }
      return ResponseModel<R>(
          errorMessage: "something went wrong",
          statusCode: 400
      );
    }

    return ResponseModel<R>(
        errorMessage: "something went wrong",
        statusCode: 400
    );

  }

//cari satışları getiriyor.
  static Future<ResponseModel<dynamic>> fetchData(String url,Map<String, dynamic> postData) async {

    try{
      var response = await _dio!.post(url,data: postData);
      var responseBody = response.data;

      if(response.statusCode == HttpStatus.ok){

        return ResponseModel<dynamic>(
            responseData: responseBody,
            statusCode: 200
        );
      }
    } on SocketException {
      return ResponseModel<dynamic>(
          errorMessage: "No internet connection",
          statusCode: 400
      );
    } on HttpException {
      return ResponseModel<dynamic>(
          errorMessage: "Invalid response",
          statusCode: 400
      );
    } on FormatException {
      return ResponseModel<dynamic>(
          errorMessage: "Invalid format",
          statusCode: 400
      );
    }on TimeoutException {
      return ResponseModel<dynamic>(
          errorMessage: "Timeout",
          statusCode: 400
      );
    }  on DioError catch(error) {
      var errorResponseData = error.response?.data;
      if(errorResponseData['errorMessage'] != null){
        return ResponseModel<dynamic>(
            errorMessage: errorResponseData['errorMessage'] ?? "",
            statusCode: int.tryParse(errorResponseData['statusCode'].toString()) ?? 400
        );
      }
      return ResponseModel<dynamic>(
          errorMessage: "something went wrong",
          statusCode: 400
      );
    } catch(e) {
      return ResponseModel<dynamic>(
          errorMessage: "$e",
          statusCode: 400
      );
    }
    return ResponseModel<dynamic>(
        errorMessage: "something went wrong",
        statusCode: 400
    );

  }

//cari arama cari dönemsel bakiye getiriyor
  static Future<ResponseModel<dynamic>> getData(String url,Map<String, dynamic> queryParameters) async {

    try{
      var response = await _dio!.get(url,queryParameters: queryParameters);
      var responseBody = response.data;


      if(response.statusCode == HttpStatus.ok){

        return ResponseModel<dynamic>(
            responseData: responseBody,
            statusCode: 200
        );
      }
    } on SocketException {
      return ResponseModel<dynamic>(
          errorMessage: "No internet connection",
          statusCode: 400
      );
    } on HttpException {
      return ResponseModel<dynamic>(
          errorMessage: "Invalid response",
          statusCode: 400
      );
    } on FormatException {
      return ResponseModel<dynamic>(
          errorMessage: "Invalid format",
          statusCode: 400
      );
    }on TimeoutException {
      return ResponseModel<dynamic>(
          errorMessage: "Timeout",
          statusCode: 400
      );
    }  on DioError catch(error) {
      var errorResponseData = error.response?.data;
      if(errorResponseData['errorMessage'] != null){
        return ResponseModel<dynamic>(
            errorMessage: errorResponseData['errorMessage'] ?? "",
            statusCode: int.tryParse(errorResponseData['statusCode'].toString()) ?? 400
        );
      }
      return ResponseModel<dynamic>(
          errorMessage: "something went wrong",
          statusCode: 400
      );
    } catch(e) {
      return ResponseModel<dynamic>(
          errorMessage: "$e",
          statusCode: 400
      );
    }
    return ResponseModel<dynamic>(
        errorMessage: "something went wrong",
        statusCode: 400
    );

  }


  ///example: APIService.fetchDataWithModel<ReturnModel,ParseModel>
  static Future<ResponseModel<R>> getDataWithModel<R,T extends BaseDataModel>(String url,Map<String, dynamic> queryParameters,T model,{String? partOfJson}) async {
    try{
      var response = await _dio!.get(url,queryParameters: queryParameters);

      if(response.statusCode == HttpStatus.ok){

        var responseBody = response.data;
        if(partOfJson != null){
          responseBody = response.data[partOfJson];
        }
        if(responseBody is List){
          return ResponseModel<R>(
              responseData: List<T>.from(responseBody.map((x) => model.fromMap(x))) as R,
              statusCode: 200
          );
        }else if(response is Map) {

          return ResponseModel<R>(

              responseData: model.fromMap(responseBody) as R,
              statusCode: 200
          );
        }

        return ResponseModel<R>(
            responseData: model.fromMap(responseBody) as R,
            statusCode: 200
        );
      }
    } on SocketException {
      return ResponseModel<R>(
          errorMessage: "İnternet bağlantısı sağlanamadı",
          statusCode: 400
      );
    } on HttpException {
      return ResponseModel<R>(
          errorMessage: "Invalid response",
          statusCode: 400
      );
    } on FormatException {
      return ResponseModel<R>(
          errorMessage: "Invalid format",
          statusCode: 400
      );
    }on TimeoutException {
      return ResponseModel<R>(
          errorMessage: "Timeout",
          statusCode: 400
      );
    } on DioError catch(error) {
      var errorResponseData = error.response?.data;

      return ResponseModel<R>(
          errorMessage: errorResponseData.toString(),
          statusCode: 400
      );
    }

    return ResponseModel<R>(
        errorMessage: "something went wrong",
        statusCode: 400
    );

  }

  static Future<ResponseModel<dynamic>> customRequest(String url) async {
    try{
      var response = await Dio(BaseOptions(connectTimeout: Duration(milliseconds: 30000),receiveTimeout: Duration(milliseconds: 30000),headers: {"Content-Type": "application/json", "apikey": apiKey})).get(url);
      var responseBody = response.data;
      if(response.statusCode == HttpStatus.ok){

        return ResponseModel<dynamic>(
            responseData: responseBody,
            statusCode: 200
        );
      }
    } on SocketException {
      return ResponseModel<dynamic>(
          errorMessage: "No internet connection",
          statusCode: 400
      );
    } on HttpException {
      return ResponseModel<dynamic>(
          errorMessage: "Invalid response",
          statusCode: 400
      );
    } on FormatException {
      return ResponseModel<dynamic>(
          errorMessage: "Invalid format",
          statusCode: 400
      );
    } on DioError catch(error) {
      var errorResponseData = error.response!.data;

      if(errorResponseData['errorMessage'] != null){
        return ResponseModel<dynamic>(
            errorMessage: errorResponseData['errorMessage'] ?? "",
            statusCode: int.tryParse(errorResponseData['statusCode'].toString()) ?? 400
        );
      }
      return ResponseModel<dynamic>(
          errorMessage: "something went wrong",
          statusCode: 400
      );
    } catch(e) {
      return ResponseModel<dynamic>(
          errorMessage: "$e",
          statusCode: 400
      );
    }
    return ResponseModel<dynamic>(
        errorMessage: "something went wrong",
        statusCode: 400
    );

  }


}




