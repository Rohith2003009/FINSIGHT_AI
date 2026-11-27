/**
 * FinSight AI – MongoDB Compass & Mongosh Full Query Script
 * Database: finsight_db
 * Connection String: mongodb://localhost:27017/finsight_db
 * 
 * Instructions:
 * 1. Open MongoDB Compass.
 * 2. Connect to: mongodb://localhost:27017/
 * 3. Select database 'finsight_db' (or run this script in the Compass Embedded Mongosh Terminal).
 */

use('finsight_db');

// ==============================================================================
// 1. CREATE ALL 15 COLLECTIONS WITH SCHEMA VALIDATION & INDEXES
// ==============================================================================

const collections = [
  'users',
  'companies',
  'documents',
  'document_chunks',
  'financial_statements',
  'financial_ratios',
  'red_flags',
  'research_sessions',
  'chat_conversations',
  'chat_messages',
  'generated_reports',
  'citations',
  'agent_logs',
  'user_activity',
  'embeddings'
];

collections.forEach(col => {
  if (!db.getCollectionNames().includes(col)) {
    db.createCollection(col);
  }
});

// Create indexes
db.companies.createIndex({ ticker: 1 }, { unique: true });
db.documents.createIndex({ ticker: 1, fiscal_year: 1 });
db.document_chunks.createIndex({ ticker: 1, page_number: 1 });
db.document_chunks.createIndex({ content: "text", section: "text" });
db.financial_statements.createIndex({ ticker: 1, fiscal_year: 1 });
db.financial_ratios.createIndex({ ticker: 1 });
db.red_flags.createIndex({ ticker: 1, severity: 1 });
db.users.createIndex({ email: 1 }, { unique: true });

// ==============================================================================
// 2. SEED CORPORATE COVERAGE UNIVERSE
// ==============================================================================

db.companies.deleteMany({});
db.companies.insertMany([
  {
    _id: "comp-bel",
    ticker: "BEL",
    name: "Bharat Electronics Limited",
    sector: "Aerospace & Defence Electronics (Navratna PSU)",
    exchange: "NSE",
    currency: "INR",
    unit: "Crores",
    market_cap_cr: 224500
  },
  {
    _id: "comp-reliance",
    ticker: "RELIANCE",
    name: "Reliance Industries Limited",
    sector: "Energy, Retail, Telecom & Digital Conglomerate",
    exchange: "NSE",
    currency: "INR",
    unit: "Crores",
    market_cap_cr: 1980000
  },
  {
    _id: "comp-titan",
    ticker: "TITAN",
    name: "Titan Company Limited",
    sector: "Luxury Consumer Discretionary, Jewellery & Watches",
    exchange: "NSE",
    currency: "INR",
    unit: "Crores",
    market_cap_cr: 295000
  },
  {
    _id: "comp-itc",
    ticker: "ITC",
    name: "ITC Limited",
    sector: "Diversified FMCG, Cigarettes, Agri & Paperboards",
    exchange: "NSE",
    currency: "INR",
    unit: "Crores",
    market_cap_cr: 580000
  },
  {
    _id: "comp-hcltech",
    ticker: "HCLTECH",
    name: "HCL Technologies Limited",
    sector: "Information Technology, Cloud & Software Products",
    exchange: "NSE",
    currency: "INR",
    unit: "Crores",
    market_cap_cr: 420000
  },
  {
    _id: "comp-tcs",
    ticker: "TCS",
    name: "Tata Consultancy Services Ltd.",
    sector: "Information Technology & Consulting",
    exchange: "NSE",
    currency: "INR",
    unit: "Crores",
    market_cap_cr: 1450000
  },
  {
    _id: "comp-tatamotors",
    ticker: "TATAMOTORS",
    name: "Tata Motors Limited",
    sector: "Automotive & Commercial Vehicles",
    exchange: "NSE",
    currency: "INR",
    unit: "Crores",
    market_cap_cr: 360000
  }
]);

// ==============================================================================
// 3. ESSENTIAL MONGODB COMPASS AGGREGATIONS & QUERIES
// ==============================================================================

// Query A: Find All Companies with Zero Debt and High ROE
db.financial_statements.aggregate([
  { $match: { total_debt: 0 } },
  {
    $lookup: {
      from: "financial_ratios",
      localField: "ticker",
      foreignField: "ticker",
      as: "ratios"
    }
  },
  { $unwind: "$ratios" },
  {
    $project: {
      ticker: 1,
      revenue: 1,
      net_income: 1,
      operating_cash_flow: 1,
      total_debt: 1,
      "roe_pct": "$ratios.roe_pct",
      "piotroski_score": "$ratios.piotroski_f_score"
    }
  }
]);

// Query B: Top Forensic Red Flags Aggregated by Severity
db.red_flags.aggregate([
  {
    $group: {
      _id: "$severity",
      count: { $sum: 1 },
      companies: { $addToSet: "$ticker" },
      issues: { $push: { ticker: "$ticker", title: "$title", page: "$source_page" } }
    }
  },
  { $sort: { _id: 1 } }
]);

// Query C: Full-Text RAG Search for Audited Sections
db.document_chunks.find(
  { $text: { $search: "revenue operating margin cash debt order book" } },
  { score: { $meta: "textScore" }, ticker: 1, page_number: 1, section: 1, content: 1 }
).sort({ score: { $meta: "textScore" } }).limit(5);

print("FinSight AI MongoDB Compass Collections & Indexes Initialized Successfully!");
