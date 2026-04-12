// Connect to db
db = db.getSiblingDB('db_rey_mikroskil');

// PROJECT 3: Subscription Snapshot
db.subscription_snapshot.insertMany([
  {
    "user_id": 101,
    "plans": [
      { "id": "P001", "code": "REY-LIFE-01", "tier": "Gold", "type": "subscription" },
      { "id": "P005", "code": "REY-FIT-01", "tier": "Silver", "type": "subscription" }
    ],
    "role": "customer",
    "initialAge": 25,
    "gender": "M"
  },
  {
    "user_id": 102,
    "plans": [
      { "id": "P002", "code": "REY-HEALTH-01", "tier": "Platinum", "type": "onetime-freemium" }
    ],
    "role": "customer",
    "initialAge": 30,
    "gender": "F"
  },
  {
    "user_id": 103,
    "plans": [
      { "id": "P001", "code": "REY-LIFE-01", "tier": "Gold", "type": "subscription" }
    ],
    "role": "agent",
    "initialAge": 28,
    "gender": "M"
  }
]);

// PROJECT 4: Plans & Benefits (Nested Structure)
db.benefit_snapshot.insertMany([
  {
    "plan_code": "REY-GOLD-01",
    "benefits": [
      { "benefit_code": "DBIREY001", "times": 10, "annual_limit": 5000000, "per_visit_limit": 500000 },
      { "benefit_code": "ANNREY002", "times": 1, "annual_limit": 1000000, "per_visit_limit": 1000000 }
    ]
  },
  {
    "plan_code": "REY-SILVER-01",
    "benefits": [
      { "benefit_code": "DBIREY001", "times": 5, "annual_limit": 2000000, "per_visit_limit": 400000 },
      { "benefit_code": "BASIC003", "times": 0, "annual_limit": 0, "per_visit_limit": 0 }
    ]
  }
]);

print("MongoDB Seeding Completed for Project 3 & 4");
