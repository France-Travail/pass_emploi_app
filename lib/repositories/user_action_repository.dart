import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/page_actions.dart';
import 'package:pass_emploi_app/models/requests/user_action_create_request.dart';
import 'package:pass_emploi_app/models/user_action.dart';
import 'package:pass_emploi_app/network/json_encoder.dart';
import 'package:pass_emploi_app/network/post_user_action_request.dart';
import 'package:pass_emploi_app/network/put_user_action_request.dart';

typedef UserActionId = String;

class UserActionRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  UserActionRepository(this._httpClient, [this._crashlytics]);

  Future<PageActions?> getPageActions(String userId) async {
    final url = '/jeunes/$userId/home/actions';
    try {
      final response = await _httpClient.get(url);
      return PageActions.fromJson(response.data);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }

  Future<bool> updateActionStatus(String actionId, UserActionStatus newStatus) async {
    final url = '/actions/$actionId';
    try {
      await _httpClient.put(
        url,
        data: customJsonEncode(PutUserActionRequest(status: newStatus)),
      );
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }

  Future<UserActionId?> createUserAction(String userId, UserActionCreateRequest request) async {
    final url = '/jeunes/$userId/action';
    try {
      final response = await _httpClient.post(
        url,
        data: customJsonEncode(PostUserActionRequest(request)),
      );
      return response.data['id'] as String;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }

  Future<bool> deleteUserAction(String actionId) async {
    final url = '/actions/$actionId';
    try {
      await _httpClient.delete(url);
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }
}
