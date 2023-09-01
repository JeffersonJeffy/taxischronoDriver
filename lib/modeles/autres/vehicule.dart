import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxischronodriver/controllers/vehiculecontroller.dart';
import 'package:taxischronodriver/varibles/variables.dart';

class Vehicule {
  String numeroDeChassie;
  String imatriculation;
  String assurance;
  DateTime expirationAssurance;
  bool isActive;
  DateTime activeEndDate;
  String token;

  String chauffeurId;
  bool
      statut; // permet de verifier que le vehicule est soit en ligne soit hors ligne.
  LatLng? position;

  Vehicule({
    required this.assurance,
    required this.expirationAssurance,
    required this.token,
    required this.imatriculation,
    required this.numeroDeChassie,
    required this.isActive,
    this.position,
    required this.activeEndDate,
    required this.chauffeurId,
    required this.statut,
  });

  Map<String, dynamic> toMap() => {
        "assurance": assurance,
        "expirationAssurance": expirationAssurance.millisecondsSinceEpoch,
        "imatriculation": imatriculation,
        "numeroDeChassie": numeroDeChassie,
        "isActive": isActive,
        "activeEndDate": activeEndDate.millisecondsSinceEpoch,
        "token": token,
        if (position != null)
          "position": {
            "latitude": position!.latitude,
            "longitude": position!.longitude,
          },
        "statut": statut,
        'chauffeurId': chauffeurId,
      };
  factory Vehicule.froJson(map) => Vehicule(
        activeEndDate:
            DateTime.fromMillisecondsSinceEpoch(map["activeEndDate"]),
        isActive: map["isActive"] ?? false,
        chauffeurId: map['chauffeurId'],
        assurance: map['assurance'],
        expirationAssurance:
            DateTime.fromMicrosecondsSinceEpoch(map['expirationAssurance']),
        imatriculation: map['imatriculation'],
        numeroDeChassie: map["numeroDeChassie"],
        token: map['token'] ?? "",
        position:
            LatLng(map['position']['latitude'], map['position']['longitude']),
        statut: map['statut'],
      );

// demande d'enrégistrement du véhicule
  Future requestSave() async {
    await bd.collection("cars").doc(chauffeurId).get().then((value) async {
      if (value.exists) {
        return "véhicule déja existant ce véhicule existe déjà";
      } else {
        await bd.collection("cars").doc(chauffeurId).set(toMap()).then((value) {
          Get.find<VehiculeController>().currentVehicul.value = this;
        });
      }
      return true;
    });
    /*await datatbase
        .ref("Vehicules")
        .child(chauffeurId)
        .get()
        .then((value) async {
      if (value.exists) {
        return "véhicule déja existant ce véhicule existe déjà";
      } else {
        await datatbase
            .ref("Vehicules")
            .child(chauffeurId)
            .set(toMap())
            .then((value) {
          Get.find<VehiculeController>().currentVehicul.value = this;
        });
      }
      return true;
    });*/
  }

// fonction de miseAjour de la position du chauffeur et ou du véhicule
  static Future setPosition(LatLng positionActuel, String userId) async {
    /*await datatbase.ref("Vehicules").child(userId).update({
      "position": {
        "latitude": positionActuel.latitude,
        "longitude": positionActuel.longitude,
      }
    });*/

    await bd.collection("cars").doc(userId).update({
      "position": {
        "latitude": positionActuel.latitude,
        "longitude": positionActuel.longitude,
      }
    });
  }

  //  actuellement en ligne ou or ligne
  setStatut(bool etatActuel) async {
    /* await datatbase
        .ref("Vehicules")
        .child(chauffeurId)
        .update({"statut": etatActuel}).then((value) async {
      if (statut == false) {
        await firestore.collection('Courses').doc(chauffeurId).delete();
      }
    });*/

    await bd
        .collection("cars")
        .doc(chauffeurId)
        .update({"statut": etatActuel}).then((value) async {
      if (statut == false) {
        await firestore.collection('Courses').doc(chauffeurId).delete();
      }
    });
  }

  static setActiveState(bool etatActuel, jours, chauffeurId) async {
    /* await datatbase
        .ref("Vehicules")
        .child(chauffeurId)
        .update({"isActive": etatActuel, "activeEndDate": jours});*/

    await bd
        .collection("cars")
        .doc(chauffeurId)
        .update({"isActive": etatActuel, "activeEndDate": jours});
  }

  /* static Stream<Vehicule> vehiculeStrem(idchau) =>
      datatbase.ref("Vehicules").child(idchau).onValue.map((event) {
        return Vehicule.froJson(event.snapshot.value);
      });*/
  static Stream<Vehicule> vehiculeStrem(idchau) {
    return bd.collection("cars").doc(idchau).snapshots().map((event) {
      return Vehicule.froJson(event.data());
    });
  }

  static Future<Vehicule?> vehiculeFuture(idchau) =>
      /*datatbase.ref("Vehicules").child(idchau).get().then((event) {
        try {
          return Vehicule.froJson(event.value);
        } catch (e) {
          null;
        }
        return null;
      });*/
      bd.collection("cars").doc(idchau).get().then((event) {
        try {
          return Vehicule.froJson(event.data());
        } catch (e) {
          null;
        }
        return null;
      });

  Stream<List<Vehicule?>> getMaisonList() {
    return bd
        .collection("cars")
        .orderBy(
          'date ajout',
          descending: true,
        )
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => Vehicule.froJson(document.data()))
            .toList());
  }

  /*static Future<List<Vehicule?>> vehiculRequette() =>
      datatbase.ref("Vehicules").get().then((event) {
        return event.children.map((vehi) {
          try {
            return Vehicule.froJson(vehi.value);
          } catch (e) {
            return null;
          }
        }).toList();
      });*/
  // fin de la classe
}
