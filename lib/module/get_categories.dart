class GetCategories{
  String caId;
  String theTitle;
  String parentCategoryId;
  String parentCategoriesCount;

  GetCategories({required this.caId, required this.theTitle, required this.parentCategoryId, required this.parentCategoriesCount});

  GetCategories.fromJson(Map json)
      : caId = json['caId'],
        theTitle = json['theTitle'],
        parentCategoryId = json['parentCategoryId'],
        parentCategoriesCount = json['parentCategoriesCount'];

}