import 'dart:convert';

IndexModel indexModelFromJson(Map<String, dynamic> s) => IndexModel.fromJson(s);

String indexModelToJson(IndexModel data) => json.encode(data.toJson());

class IndexModel {
  User? user;
  List<IndexListModel> files;
  List<IndexListModel> recent;
  List<IndexListModel> top;

  IndexModel({
    required this.recent,
    required this.top,
    required this.files,
    required this.user,
  });

  Map<String, dynamic> toJson() => {
    "recent": List<dynamic>.from(recent.map((x) => x.toJson())),
    "files": List<dynamic>.from(files.map((x) => x.toJson())),
    "user": user?.toJson(),
    "top": List<dynamic>.from(top.map((x) => x.toJson())),
  };

  factory IndexModel.fromJson(Map<String, dynamic> json) => IndexModel(
    files: List<IndexListModel>.from(
      json["submerge"] != null
          ? json["submerge"].map((x) => IndexListModel.fromJson(x))
          : [],
    ),
    user: json["portlily"] != null ? User.fromJson(json["portlily"]) : null,
    top: List<IndexListModel>.from(
      json["chalcidic"] != null
          ? json["chalcidic"].map((x) => IndexListModel.fromJson(x))
          : [],
    ),
    recent: List<IndexListModel>.from(
      json["bagobo"] != null
          ? json["bagobo"].map((x) => IndexListModel.fromJson(x))
          : [],
    ),
  );
}

class IndexListModel {
  String id;
  int createTime;
  FileMeta fileMeta;
  Namespace namespace;
  DisPlayName disPlayName;
  int vidQty;
  int updateTime;
  bool finished;
  bool invalid;
  bool directory;
  bool video;

  IndexListModel({
    required this.id,
    required this.video,
    required this.fileMeta,
    required this.namespace,
    required this.disPlayName,
    required this.invalid,
    required this.directory,
    required this.createTime,
    required this.updateTime,
    required this.finished,
    required this.vidQty,
  });

  factory IndexListModel.fromJson(Map<String, dynamic> json) => IndexListModel(
    id: json["apojove"] ?? '',
    finished: json["foreshow"] ?? false,
    updateTime: json["bespout"] ?? 0,
    fileMeta: FileMeta.fromJson(json["choyaroot"]),
    namespace: Namespace.fromJson(json["5uuu1au8wp"]),
    createTime: json["harems"] ?? 0,
    disPlayName: DisPlayName.fromJson(json["paramarine"]),
    invalid: json["unascribed"] ?? false,
    directory: json["vxz_38but7"] ?? false,
    video: json["klong"] ?? false,
    vidQty: json["overbade"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "file_meta": fileMeta.toJson(),
    "namespace": namespace.toJson(),
    "disPlayName": disPlayName.toJson(),
    "invalid": invalid,
    "vid_qty": vidQty,
    "create_time": createTime,
    "update_time": updateTime,
    "finished": finished,
  };
}

class FileMeta {
  String type;
  String mimeType;
  String extension;
  String thumbnail;
  int size;

  FileMeta({
    required this.type,
    required this.size,
    required this.extension,
    required this.thumbnail,
    required this.mimeType,
  });

  factory FileMeta.fromJson(Map<String, dynamic> json) => FileMeta(
    type: json["hq69c3xeuq"] ?? '',
    size: json["celioscope"] ?? 0,
    thumbnail: json["luceres"] ?? '',
    mimeType: json["qofjuhze7c"] ?? '',
    extension: json["wwbn1gqofp"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "size": size,
    "mime_type": mimeType,
    "extension": extension,
    "thumbnail": thumbnail,
  };
}

class DisPlayName {
  String carrow;
  DisPlayName({required this.carrow});

  factory DisPlayName.fromJson(Map<String, dynamic> json) =>
      DisPlayName(carrow: json["carrow"] ?? '');

  Map<String, dynamic> toJson() => {"carrow": carrow};
}

class Namespace {
  NoModel no;
  Namespace({required this.no});
  // dignify/reindebted/aromacity
  factory Namespace.fromJson(Map<String, dynamic> json) =>
      Namespace(no: NoModel.fromJson(json["no"]));

  Map<String, dynamic> toJson() => {"no": no.toJson()};
}

class NoModel {
  Homonid homonid;
  NoModel({required this.homonid});

  factory NoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
        return NoModel(homonid: Homonid.fromJson({}));
    }
    return NoModel(homonid: Homonid.fromJson(json["homonid"]));
  }


  Map<String, dynamic> toJson() => {"homonid": homonid.toJson()};
}

class Homonid {
  String id;
  String name;
  Tenant tenant;
  int createTime;

  Homonid({
    required this.id,
    required this.tenant,
    required this.createTime,
    required this.name,
  });

  factory Homonid.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Homonid(
          id: '', createTime: 0, name: '', tenant: Tenant.fromJson({}));
    }
    return Homonid(
      id: json["apojove"] ?? '',
      createTime: json["harems"] ?? 0,
      name: json["binous"] ?? '',
      tenant: Tenant.fromJson(json["cowcatcher"]),
    );
  }
    Map<String, dynamic> toJson() => {
      "id": id,
      "create_time": createTime,
      "name": name,
      "tenant": tenant.toJson(),
    };
}

class Tenant {
  String id;
  int createTime;
  int accessExpiredTime;
  String name;
  String accessId;

  Tenant({
    required this.id,
    required this.accessId,
    required this.accessExpiredTime,
    required this.createTime,
    required this.name,
  });

  factory Tenant.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Tenant(
          id: '', createTime: 0, accessExpiredTime: 0, name: '', accessId: '');
    }
    return Tenant(
      id: json["apojove"] ?? '',
      createTime: json["harems"] ?? 0,
      accessExpiredTime: json["reddy"] ?? 0,
      name: json["binous"] ?? '',
      accessId: json["repps"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime,
    "access_expired_time": accessExpiredTime,
    "name": name,
    "access_id": accessId,
  };
}

class User {
  String id;
  String account;
  String name;
  String email;
  String picture;
  List<Label> labels;

  User({
    required this.id,
    required this.account,
    required this.name,
    required this.email,
    required this.picture,
    required this.labels,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["apojove"] ?? '',
    account: json["parolable"] ?? '',
    name: json["binous"] ?? '',

    labels: List<Label>.from(json["miscalling"].map((x) => Label.fromJson(x))),
    email: json["befleck"] ?? '',
    picture: json["orvietan"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "picture": picture,
    "labels": List<dynamic>.from(labels.map((x) => x.toJson())),

    "account": account,
    "name": name,
    "email": email,
  };
}

class Label {
  String id;
  String firstLabelCode;
  String secondLabelCode;
  String labelName;

  Label({
    required this.id,

    required this.secondLabelCode,
    required this.labelName,
    required this.firstLabelCode,
  });

  factory Label.fromJson(Map<String, dynamic> json) => Label(
    id: json["apojove"] ?? '',
    firstLabelCode: json["vxmen9fuhl"] ?? '',
    secondLabelCode: json["octangle"] ?? '',
    labelName: json["vias"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "second_label_code": secondLabelCode,
    "label_name": labelName,
    "first_label_code": firstLabelCode,
  };
}

class UserPools {
  String id;
  String account;
  String name;
  String email;
  String picture;
  int updateDate;
  int platform;
  int recommend;
  List<UserLabel> labels;
  String telegramUrl;
  String bannerPictureUrl;
  String telegramAddress;

  UserPools({
    required this.id,
    required this.account,
    required this.name,
    required this.bannerPictureUrl,
    required this.telegramAddress,
    required this.email,
    required this.picture,
    required this.labels,
    required this.telegramUrl,
    this.updateDate = 0,
    this.platform = 0,
    this.recommend = 0,
  });

  factory UserPools.fromJson(Map<String, dynamic> json) => UserPools(
    id: json["id"] ?? '',
    account: json["account"] ?? '',
    name: json["name"] ?? '',
    telegramUrl: json["telegramUrl"] ?? '',
    bannerPictureUrl: json["bannerPictureUrl"] ?? '',
    telegramAddress: json["telegramAddress"] ?? '',
    email: json["email"] ?? '',
    picture: json["picture"] ?? '',
    labels: List<UserLabel>.from(
      json["labels"].map((x) => UserLabel.fromJson(x)),
    ),

    updateDate: json["updateDate"] ?? 0,
    platform: json["platform"] ?? 0,
    recommend: json["recommend"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "account": account,
    "name": name,
    "telegramAddress": telegramAddress,
    "updateDate": updateDate,
    "platform": platform,
    "email": email,
    "picture": picture,
    "labels": List<dynamic>.from(labels.map((x) => x.toJson())),
    "telegramUrl": telegramUrl,
    "bannerPictureUrl": bannerPictureUrl,
    "recommend": recommend,
  };
}

class UserLabel {
  String id;
  String labelName;
  String secondLabelCode;
  String firstLabelCode;

  UserLabel({
    required this.id,
    required this.firstLabelCode,
    required this.secondLabelCode,
    required this.labelName,
  });

  factory UserLabel.fromJson(Map<String, dynamic> json) => UserLabel(
    secondLabelCode: json["second_label_code"] ?? '',
    id: json["id"] ?? '',
    labelName: json["label_name"] ?? '',
    firstLabelCode: json["first_label_code"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_label_code": firstLabelCode,
    "second_label_code": secondLabelCode,
    "label_name": labelName,
  };
}
