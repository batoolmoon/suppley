class GetCountries{
  String coId;
  String countryName;

  GetCountries({required this.coId, required this.countryName});

  GetCountries.fromJson(Map json)
      : coId = json['coId'],
        countryName = json['countryName'];


}

