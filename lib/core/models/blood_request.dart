class BloodRequest {
  final String id;
  final String patient;
  final String postedBy;
  final String postedById;
  final String hospital;
  final String bloodType;
  final int units;
  final String urgency;
  final double lat;
  final double lng;
  final String contact;
  final String status; // active, accepted, on_the_way, donor_confirmed, fulfilled, disputed
  final String? acceptedBy;
  final String? acceptedById;
  final DateTime? acceptedAt;
  final DateTime? donorConfirmedAt;
  final int? unitsConfirmedByDonor;
  final int? unitsConfirmedByRequester;
  final String? disputeReason;
  final DateTime createdAt;

  BloodRequest({
    required this.id,
    required this.patient,
    this.postedBy = '',
    this.postedById = '',
    required this.hospital,
    required this.bloodType,
    required this.units,
    required this.urgency,
    required this.lat,
    required this.lng,
    required this.contact,
    this.status = 'active',
    this.acceptedBy,
    this.acceptedById,
    this.acceptedAt,
    this.donorConfirmedAt,
    this.unitsConfirmedByDonor,
    this.unitsConfirmedByRequester,
    this.disputeReason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BloodRequest.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      // Handles Firestore Timestamp if available without hard dependency
      try {
        return (val as dynamic).toDate() as DateTime?;
      } catch (_) {
        return null;
      }
    }

    int parseUnits(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 1;
      return 1;
    }

    double parseDouble(dynamic val) {
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return BloodRequest(
      id: map['id']?.toString() ?? '',
      patient: map['patient']?.toString() ?? '',
      postedBy: map['postedBy']?.toString() ?? '',
      postedById: map['postedById']?.toString() ?? '',
      hospital: map['hospital']?.toString() ?? '',
      bloodType: map['bloodType']?.toString() ?? '',
      units: parseUnits(map['units']),
      urgency: map['urgency']?.toString() ?? 'Normal',
      lat: parseDouble(map['lat']),
      lng: parseDouble(map['lng']),
      contact: map['contact']?.toString() ?? '',
      status: map['status']?.toString() ?? 'active',
      acceptedBy: map['acceptedBy']?.toString(),
      acceptedById: map['acceptedById']?.toString(),
      acceptedAt: parseDate(map['acceptedAt']),
      donorConfirmedAt: parseDate(map['donorConfirmedAt']),
      unitsConfirmedByDonor: map['unitsConfirmedByDonor'] != null ? parseUnits(map['unitsConfirmedByDonor']) : null,
      unitsConfirmedByRequester: map['unitsConfirmedByRequester'] != null ? parseUnits(map['unitsConfirmedByRequester']) : null,
      disputeReason: map['disputeReason']?.toString(),
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient': patient,
      'postedBy': postedBy,
      'postedById': postedById,
      'hospital': hospital,
      'bloodType': bloodType,
      'units': units,
      'urgency': urgency,
      'lat': lat,
      'lng': lng,
      'contact': contact,
      'status': status,
      'acceptedBy': acceptedBy,
      'acceptedById': acceptedById,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'donorConfirmedAt': donorConfirmedAt?.toIso8601String(),
      'unitsConfirmedByDonor': unitsConfirmedByDonor,
      'unitsConfirmedByRequester': unitsConfirmedByRequester,
      'disputeReason': disputeReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BloodRequest copyWith({
    String? id,
    String? patient,
    String? postedBy,
    String? postedById,
    String? hospital,
    String? bloodType,
    int? units,
    String? urgency,
    double? lat,
    double? lng,
    String? contact,
    String? status,
    String? acceptedBy,
    String? acceptedById,
    DateTime? acceptedAt,
    DateTime? donorConfirmedAt,
    int? unitsConfirmedByDonor,
    int? unitsConfirmedByRequester,
    String? disputeReason,
    DateTime? createdAt,
  }) {
    return BloodRequest(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      postedBy: postedBy ?? this.postedBy,
      postedById: postedById ?? this.postedById,
      hospital: hospital ?? this.hospital,
      bloodType: bloodType ?? this.bloodType,
      units: units ?? this.units,
      urgency: urgency ?? this.urgency,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      acceptedById: acceptedById ?? this.acceptedById,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      donorConfirmedAt: donorConfirmedAt ?? this.donorConfirmedAt,
      unitsConfirmedByDonor: unitsConfirmedByDonor ?? this.unitsConfirmedByDonor,
      unitsConfirmedByRequester: unitsConfirmedByRequester ?? this.unitsConfirmedByRequester,
      disputeReason: disputeReason ?? this.disputeReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
