# Live Code: MongoDB Aggregation Pipeline
## Studi Kasus: JSON Extraction & Transformation (REY)

Pastikan MongoDB sudah berjalan di Docker.

---

### Langkah 1: Melihat Struktur Data (Project 3)
Gunakan MongoDB Compass atau terminal mongosh.
```javascript
// Cek koleksi
db.subscription_snapshot.find().pretty();
```

### Langkah 2: Meratakan Data (Flattening with $unwind)
Tujuannya adalah membuat satu baris per plan, meskipun user-nya sama.
```javascript
db.subscription_snapshot.aggregate([
  { $unwind: "$plans" },
  { 
    $project: {
      user_id: 1,
      plan_code: "$plans.code",
      plan_tier: "$plans.tier",
      plan_type: "$plans.type"
    }
  }
]);
```

### Langkah 3: Menghitung User per Plan (Grouping)
```javascript
db.subscription_snapshot.aggregate([
  { $unwind: "$plans" },
  { 
    $group: {
      _id: "$plans.id",
      total_users: { $sum: 1 }
    }
  }
]);
```

### Langkah 4: Membersihkan Data "Sampah" (Project 4)
Kita ingin mengambil benefit yang valid saja (`times > 0`).
```javascript
db.benefit_snapshot.aggregate([
  { $unwind: "$benefits" },
  { 
    $match: {
      "benefits.times": { $gt: 0 }
    }
  },
  {
    $project: {
      _id: 0,
      plan_code: 1,
      benefit_code: "$benefits.benefit_code",
      times: "$benefits.times",
      annual_limit: "$benefits.annual_limit"
    }
  }
]);
```

### Tips AI-Augmented
Jika Anda lupa sintaks `$unwind`, Anda bisa bertanya ke AI:
> "How to convert an array of objects in MongoDB into multiple documents based on each object in the array?"
