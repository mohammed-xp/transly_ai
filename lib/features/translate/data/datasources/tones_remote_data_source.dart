import '../models/tone_catalog_model.dart';

abstract class TonesRemoteDataSource {
  Future<ToneCatalogModel> getTones();
}
