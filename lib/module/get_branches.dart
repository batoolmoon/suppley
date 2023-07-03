class GetBranches{
  String coId;
  String theBranchName;

  GetBranches({required this.coId, required this.theBranchName});

  GetBranches.fromJson(Map json)
      : coId = json['coId'],
        theBranchName = json['theBranchName'];

}