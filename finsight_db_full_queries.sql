-- ==============================================================================
-- PROJECT: FinSight AI – Multi-Agent Financial Research System
-- SCRIPT: Complete Database Schema, Seed Ingestion & Institutional Queries
-- DATABASE NAME: finsight_db
-- COMPATIBILITY: PostgreSQL, MySQL, Cloud SQL, SQLite, and MongoDB Compass Relational/SQL View
-- CREATED FOR: Equity Research Analysts, Financial Engineers, and DB Administrators
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- PART 1: SCHEMA DEFINITION (TABLES, CONSTRAINTS & INDEXES)
-- ------------------------------------------------------------------------------

-- 1. USERS & ANALYST PERMISSIONS
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(64) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(128) DEFAULT 'Equity Research Analyst',
    institution VARCHAR(255) DEFAULT 'Institutional Research & Analytics',
    is_admin BOOLEAN DEFAULT FALSE,
    status VARCHAR(32) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. COVERAGE UNIVERSE / COMPANIES
CREATE TABLE IF NOT EXISTS companies (
    id VARCHAR(64) PRIMARY KEY,
    ticker VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    sector VARCHAR(255) NOT NULL,
    exchange VARCHAR(32) DEFAULT 'NSE',
    currency VARCHAR(16) DEFAULT 'INR',
    unit VARCHAR(32) DEFAULT 'Crores',
    market_cap_cr NUMERIC(15, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. STATUTORY FILINGS & ANNUAL REPORTS
CREATE TABLE IF NOT EXISTS documents (
    id VARCHAR(64) PRIMARY KEY,
    company_id VARCHAR(64) REFERENCES companies(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    ticker VARCHAR(32) NOT NULL,
    fiscal_year VARCHAR(16) NOT NULL,
    filing_type VARCHAR(64) DEFAULT 'Annual Report',
    filing_date DATE NOT NULL,
    page_count INTEGER NOT NULL,
    file_size VARCHAR(32) NOT NULL,
    status VARCHAR(32) DEFAULT 'indexed',
    chunks_count INTEGER DEFAULT 0,
    summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. PARSED DOCUMENT CHUNKS & VECTOR EMBEDDINGS
CREATE TABLE IF NOT EXISTS document_chunks (
    id VARCHAR(64) PRIMARY KEY,
    document_id VARCHAR(64) REFERENCES documents(id) ON DELETE CASCADE,
    ticker VARCHAR(32) NOT NULL,
    fiscal_year VARCHAR(16) NOT NULL,
    page_number INTEGER NOT NULL,
    section VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    metrics_mentioned TEXT[],
    embedding_vector_id VARCHAR(128),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. AUDITED FINANCIAL STATEMENTS
CREATE TABLE IF NOT EXISTS financial_statements (
    id VARCHAR(64) PRIMARY KEY,
    company_id VARCHAR(64) REFERENCES companies(id) ON DELETE CASCADE,
    ticker VARCHAR(32) NOT NULL,
    fiscal_year VARCHAR(16) NOT NULL,
    currency VARCHAR(16) DEFAULT 'INR',
    unit VARCHAR(32) DEFAULT 'Crores',
    -- Income Statement
    revenue NUMERIC(15, 2) NOT NULL,
    revenue_growth_pct NUMERIC(6, 2),
    cost_of_revenue NUMERIC(15, 2),
    gross_profit NUMERIC(15, 2),
    gross_margin_pct NUMERIC(6, 2),
    operating_expenses NUMERIC(15, 2),
    operating_income NUMERIC(15, 2),
    operating_margin_pct NUMERIC(6, 2),
    ebitda NUMERIC(15, 2),
    net_income NUMERIC(15, 2) NOT NULL,
    net_margin_pct NUMERIC(6, 2),
    eps NUMERIC(8, 2),
    -- Balance Sheet
    cash_and_equivalents NUMERIC(15, 2) NOT NULL,
    accounts_receivable NUMERIC(15, 2),
    inventory NUMERIC(15, 2),
    current_assets NUMERIC(15, 2),
    total_assets NUMERIC(15, 2) NOT NULL,
    current_liabilities NUMERIC(15, 2),
    long_term_debt NUMERIC(15, 2) DEFAULT 0.00,
    total_debt NUMERIC(15, 2) DEFAULT 0.00,
    total_liabilities NUMERIC(15, 2),
    shareholders_equity NUMERIC(15, 2) NOT NULL,
    -- Cash Flows
    operating_cash_flow NUMERIC(15, 2) NOT NULL,
    investing_cash_flow NUMERIC(15, 2),
    financing_cash_flow NUMERIC(15, 2),
    capital_expenditure NUMERIC(15, 2) NOT NULL,
    free_cash_flow NUMERIC(15, 2) NOT NULL,
    -- Order Book & Disclosures
    order_book NUMERIC(15, 2) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. COMPUTED FINANCIAL RATIOS & MODELS
CREATE TABLE IF NOT EXISTS financial_ratios (
    id VARCHAR(64) PRIMARY KEY,
    company_id VARCHAR(64) REFERENCES companies(id) ON DELETE CASCADE,
    ticker VARCHAR(32) NOT NULL,
    fiscal_year VARCHAR(16) NOT NULL,
    pe_ratio NUMERIC(8, 2),
    pb_ratio NUMERIC(8, 2),
    ev_ebitda NUMERIC(8, 2),
    roe_pct NUMERIC(6, 2),
    roce_pct NUMERIC(6, 2),
    debt_to_equity NUMERIC(6, 2),
    current_ratio NUMERIC(6, 2),
    quick_ratio NUMERIC(6, 2),
    dividend_yield_pct NUMERIC(6, 2),
    dividend_payout_pct NUMERIC(6, 2),
    piotroski_f_score INTEGER CHECK (piotroski_f_score BETWEEN 0 AND 9),
    altman_z_score NUMERIC(6, 2),
    altman_zone VARCHAR(32), -- 'Safe', 'Grey', 'Distress'
    -- DuPont Decomposition Factors
    dupont_tax_burden NUMERIC(6, 4),
    dupont_interest_burden NUMERIC(6, 4),
    dupont_operating_margin NUMERIC(6, 4),
    dupont_asset_turnover NUMERIC(6, 4),
    dupont_equity_multiplier NUMERIC(6, 4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. AUTONOMOUS RED FLAGS & ANOMALY DETECTIONS
CREATE TABLE IF NOT EXISTS red_flags (
    id VARCHAR(64) PRIMARY KEY,
    company_id VARCHAR(64) REFERENCES companies(id) ON DELETE CASCADE,
    ticker VARCHAR(32) NOT NULL,
    title VARCHAR(255) NOT NULL,
    severity VARCHAR(32) NOT NULL, -- 'High', 'Medium', 'Low'
    category VARCHAR(128) NOT NULL,
    description TEXT NOT NULL,
    evidence_quote TEXT NOT NULL,
    source_document VARCHAR(255) NOT NULL,
    source_page INTEGER NOT NULL,
    potential_impact TEXT,
    suggested_investigation TEXT,
    status VARCHAR(32) DEFAULT 'detected',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. RESEARCH WORKSPACES & CONVERSATIONS
CREATE TABLE IF NOT EXISTS research_sessions (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) REFERENCES users(id) ON DELETE CASCADE,
    company_ticker VARCHAR(32) NOT NULL,
    title VARCHAR(255) NOT NULL,
    session_notes TEXT,
    status VARCHAR(32) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id VARCHAR(64) PRIMARY KEY,
    session_id VARCHAR(64) REFERENCES research_sessions(id) ON DELETE CASCADE,
    sender_role VARCHAR(32) NOT NULL, -- 'user', 'assistant'
    agent_name VARCHAR(64) DEFAULT 'Research Agent',
    message_content TEXT NOT NULL,
    citations_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. COMPILED INSTITUTIONAL RESEARCH REPORTS
CREATE TABLE IF NOT EXISTS generated_reports (
    id VARCHAR(64) PRIMARY KEY,
    company_id VARCHAR(64) REFERENCES companies(id) ON DELETE CASCADE,
    ticker VARCHAR(32) NOT NULL,
    fiscal_year VARCHAR(16) NOT NULL,
    title VARCHAR(255) NOT NULL,
    analyst_rating VARCHAR(64) DEFAULT 'Overweight / Buy',
    target_price_inr NUMERIC(10, 2),
    executive_summary TEXT NOT NULL,
    financial_performance_summary TEXT,
    ratio_analysis_summary TEXT,
    red_flag_audit_summary TEXT,
    research_conclusion TEXT,
    pdf_download_ready BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. SYSTEM AUDIT & MULTI-AGENT EXECUTION LOGS
CREATE TABLE IF NOT EXISTS agent_logs (
    id VARCHAR(64) PRIMARY KEY,
    agent_name VARCHAR(64) NOT NULL,
    execution_step VARCHAR(255) NOT NULL,
    duration_ms INTEGER DEFAULT 0,
    status VARCHAR(32) DEFAULT 'success',
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INDEXES FOR FAST RETRIEVAL
CREATE INDEX IF NOT EXISTS idx_chunks_ticker ON document_chunks(ticker);
CREATE INDEX IF NOT EXISTS idx_chunks_page ON document_chunks(page_number);
CREATE INDEX IF NOT EXISTS idx_financials_ticker_fy ON financial_statements(ticker, fiscal_year);
CREATE INDEX IF NOT EXISTS idx_red_flags_ticker ON red_flags(ticker);
CREATE INDEX IF NOT EXISTS idx_red_flags_severity ON red_flags(severity);


-- ------------------------------------------------------------------------------
-- PART 2: SEED DATA POPULATION
-- ------------------------------------------------------------------------------

-- Insert Pre-Loaded Users
INSERT INTO users (id, email, password_hash, name, role, institution, is_admin, status) VALUES
('usr-admin-root', 'admin@gmail.com', 'admin@123', 'System Administrator', 'Lead Platform Administrator', 'FinSight AI Core Operations', TRUE, 'active'),
('usr-analyst-demo', 'rohithv3009@gmail.com', 'RohithFinSight@2025', 'Rohith V', 'Senior Equity Research Analyst', 'Institutional Research & Analytics', FALSE, 'active'),
('usr-analyst-priya', 'priya.sharma@investments.in', 'Priya@FinSight25', 'Priya Sharma', 'Equity Research Analyst', 'Kotak Institutional Equities', FALSE, 'active')
ON CONFLICT (id) DO NOTHING;

-- Insert Coverage Companies
INSERT INTO companies (id, ticker, name, sector, exchange, currency, unit, market_cap_cr) VALUES
('comp-bel', 'BEL', 'Bharat Electronics Limited', 'Aerospace & Defence Electronics (Navratna PSU)', 'NSE', 'INR', 'Crores', 224500.00),
('comp-reliance', 'RELIANCE', 'Reliance Industries Limited', 'Energy, Retail, Telecom & Digital Conglomerate', 'NSE', 'INR', 'Crores', 1980000.00),
('comp-titan', 'TITAN', 'Titan Company Limited', 'Luxury Consumer Discretionary, Jewellery & Watches', 'NSE', 'INR', 'Crores', 295000.00),
('comp-itc', 'ITC', 'ITC Limited', 'Diversified FMCG, Cigarettes, Agri & Paperboards', 'NSE', 'INR', 'Crores', 580000.00),
('comp-hcltech', 'HCLTECH', 'HCL Technologies Limited', 'Information Technology, Cloud & Software Products', 'NSE', 'INR', 'Crores', 420000.00),
('comp-tcs', 'TCS', 'Tata Consultancy Services Ltd.', 'Information Technology & Consulting', 'NSE', 'INR', 'Crores', 1450000.00),
('comp-tatamotors', 'TATAMOTORS', 'Tata Motors Limited', 'Automotive & Commercial Vehicles', 'NSE', 'INR', 'Crores', 360000.00)
ON CONFLICT (id) DO NOTHING;

-- Insert Statutory Annual Reports
INSERT INTO documents (id, company_id, company_name, ticker, fiscal_year, filing_type, filing_date, page_count, file_size, status, chunks_count, summary) VALUES
('doc-bel-fy25', 'comp-bel', 'Bharat Electronics Limited', 'BEL', 'FY2025', 'Annual Report', '2025-05-24', 320, '15.2 MB', 'indexed', 46, 'Provisional & Audited Annual Review FY2024-25. Revenue of 23,850 Cr (+17.7% YoY) and Net Profit of 4,820 Cr (+21.0% YoY). Order book surpasses 78,500 Cr with zero long-term debt.'),
('doc-bel-fy24', 'comp-bel', 'Bharat Electronics Limited', 'BEL', 'FY2024', 'Annual Report', '2024-05-20', 312, '14.8 MB', 'indexed', 44, '70th Integrated Annual Report 2023-24. Consolidated revenue from operations reached 20,268 Cr (+14.3% YoY) with Net Profit of 3,985 Cr (+33.4% YoY). Unexecuted order book of 75,934 Cr gives ~3.8 years revenue visibility.'),
('doc-reliance-fy25', 'comp-reliance', 'Reliance Industries Limited', 'RELIANCE', 'FY2025', 'Annual Report', '2025-07-20', 520, '24.5 MB', 'indexed', 65, 'Consolidated Annual Review FY2024-25. Revenue approaches 10 lakh crore at 9,94,500 Cr with EBITDA of 1,98,000 Cr and Net Profit of 76,200 Cr.'),
('doc-titan-fy25', 'comp-titan', 'Titan Company Limited', 'TITAN', 'FY2025', 'Annual Report', '2025-06-15', 330, '16.2 MB', 'indexed', 48, 'Annual Report FY2024-25. Consolidated revenue accelerates to 56,800 Cr (+20.6% YoY) with Net Profit of 4,220 Cr (+20.7% YoY).'),
('doc-itc-fy25', 'comp-itc', 'ITC Limited', 'ITC', 'FY2025', 'Annual Report', '2025-06-22', 375, '18.1 MB', 'indexed', 52, 'Annual Review FY2024-25. Revenue expands to 83,400 Cr (+8.5% YoY) with Net Profit of 22,350 Cr. Successful demerger of ITC Hotels Ltd.'),
('doc-hcltech-fy25', 'comp-hcltech', 'HCL Technologies Limited', 'HCLTECH', 'FY2025', 'Annual Report', '2025-05-15', 356, '17.8 MB', 'indexed', 50, 'Annual Report FY2024-25. Consolidated revenue rises to 1,19,400 Cr (+8.6% YoY) with Net Profit of 17,250 Cr and operating margin of 18.6%.')
ON CONFLICT (id) DO NOTHING;

-- Insert Document Chunks with Statutory Provenance
INSERT INTO document_chunks (id, document_id, ticker, fiscal_year, page_number, section, content) VALUES
('chunk-bel-01', 'doc-bel-fy25', 'BEL', 'FY2025', 140, 'Audited Statement of Profit and Loss', 'Revenue from operations was 23,850 crore compared to 20,268 crore in FY24, representing growth of 17.7%. Operating profit before exceptional items stood at 6,060 crore with an operating margin of 25.41%. Profit after tax was 4,820 crore. The company carries zero debt and maintains a healthy liquidity buffer of 9,850 crore in cash and bank balances.'),
('chunk-bel-02', 'doc-bel-fy25', 'BEL', 'FY2025', 48, 'Directors Report - Order Book Status', 'Order book as on 31st March 2025 stood robust at 78,500 crore, reflecting solid order inflows from Indian Defence Services. Major programmes include Akash missile systems, advanced electronic warfare suites, software defined radios, and coastal radar networks.'),
('chunk-bel-03', 'doc-bel-fy25', 'BEL', 'FY2025', 64, 'Risk Management Disclosures', 'A major portion of our supplies are to the Indian Armed Services. Over 82% of revenue is dependent on Ministry of Defence procurement allocations and DAP milestone clearances.'),
('chunk-reliance-01', 'doc-reliance-fy25', 'RELIANCE', 'FY2025', 236, 'Consolidated Financial Statements', 'Consolidated revenue approached 9,94,500 crore with EBITDA of 1,98,000 crore and Net Profit of 76,200 crore. Total gross debt was 3,18,000 crore against capital expenditure of 1,22,000 crore across 5G networks and retail expansion.'),
('chunk-titan-01', 'doc-titan-fy25', 'TITAN', 'FY2025', 162, 'Audited Statement of Profit and Loss', 'Revenue from operations reached 56,800 crore (+20.6% YoY) with EBIT of 5,150 crore and Net Profit of 4,220 crore. Gold inventory stood at 20,500 crore funded predominantly via Gold Metal Loans (GML).'),
('chunk-itc-01', 'doc-itc-fy25', 'ITC', 'FY2025', 170, 'Consolidated Operations', 'Gross revenue from operations stood at 83,400 crore with segment operating profit of 30,850 crore (36.99% margin). Net Profit reached 22,350 crore with zero debt and cash reserves exceeding 15,000 crore.')
ON CONFLICT (id) DO NOTHING;

-- Insert Audited Financial Statements
INSERT INTO financial_statements (
    id, company_id, ticker, fiscal_year, currency, unit,
    revenue, revenue_growth_pct, cost_of_revenue, gross_profit, gross_margin_pct,
    operating_expenses, operating_income, operating_margin_pct, ebitda, net_income, net_margin_pct, eps,
    cash_and_equivalents, accounts_receivable, inventory, current_assets, total_assets,
    current_liabilities, long_term_debt, total_debt, total_liabilities, shareholders_equity,
    operating_cash_flow, investing_cash_flow, financing_cash_flow, capital_expenditure, free_cash_flow, order_book
) VALUES
('fin-bel-fy25', 'comp-bel', 'BEL', 'FY2025', 'INR', 'Crores',
 23850.00, 17.67, 13350.00, 10500.00, 44.02, 4440.00, 6060.00, 25.41, 6580.00, 4820.00, 20.21, 6.59,
 9850.00, 7600.00, 6400.00, 26500.00, 33800.00, 11400.00, 0.00, 0.00, 13200.00, 20600.00,
 5450.00, -1200.00, -2400.00, 950.00, 4500.00, 78500.00),
('fin-reliance-fy25', 'comp-reliance', 'RELIANCE', 'FY2025', 'INR', 'Crores',
 994500.00, 8.75, 642000.00, 352500.00, 35.45, 218500.00, 134000.00, 13.47, 198000.00, 76200.00, 7.66, 112.65,
 158000.00, 31200.00, 152000.00, 462000.00, 1824000.00, 418000.00, 242000.00, 318000.00, 1042000.00, 782000.00,
 162000.00, -125000.00, -34000.00, 122000.00, 40000.00, NULL),
('fin-titan-fy25', 'comp-titan', 'TITAN', 'FY2025', 'INR', 'Crores',
 56800.00, 20.60, 42100.00, 14700.00, 25.88, 9550.00, 5150.00, 9.07, 5850.00, 4220.00, 7.43, 47.53,
 2400.00, 1100.00, 20500.00, 24500.00, 28700.00, 16900.00, 1200.00, 9400.00, 15200.00, 13500.00,
 3800.00, -950.00, -1850.00, 850.00, 2950.00, NULL),
('fin-itc-fy25', 'comp-itc', 'ITC', 'FY2025', 'INR', 'Crores',
 83400.00, 8.50, 38500.00, 44900.00, 53.84, 15700.00, 29200.00, 35.01, 30850.00, 22350.00, 26.80, 17.92,
 15200.00, 3800.00, 12400.00, 34200.00, 101800.00, 12000.00, 0.00, 0.00, 23100.00, 78700.00,
 18900.00, -4200.00, -11200.00, 3500.00, 15400.00, NULL)
ON CONFLICT (id) DO NOTHING;

-- Insert Financial Ratios and DuPont Factors
INSERT INTO financial_ratios (
    id, company_id, ticker, fiscal_year,
    pe_ratio, pb_ratio, ev_ebitda, roe_pct, roce_pct, debt_to_equity,
    current_ratio, quick_ratio, dividend_yield_pct, dividend_payout_pct,
    piotroski_f_score, altman_z_score, altman_zone,
    dupont_tax_burden, dupont_interest_burden, dupont_operating_margin, dupont_asset_turnover, dupont_equity_multiplier
) VALUES
('ratio-bel-fy25', 'comp-bel', 'BEL', 'FY2025',
 44.50, 10.40, 32.40, 23.40, 27.05, 0.00,
 2.32, 1.76, 1.15, 42.50,
 8, 6.42, 'Safe',
 0.7954, 1.0000, 0.2541, 0.7056, 1.6408),
('ratio-reliance-fy25', 'comp-reliance', 'RELIANCE', 'FY2025',
 24.80, 2.42, 11.20, 9.74, 11.20, 0.41,
 1.10, 0.74, 0.36, 8.80,
 6, 2.84, 'Grey',
 0.7100, 0.8010, 0.1347, 0.5452, 2.3325),
('ratio-titan-fy25', 'comp-titan', 'TITAN', 'FY2025',
 82.40, 24.10, 48.20, 31.20, 34.50, 0.69,
 1.45, 0.38, 0.32, 25.00,
 7, 4.85, 'Safe',
 0.8194, 0.9400, 0.0907, 1.9791, 2.1259),
('ratio-itc-fy25', 'comp-itc', 'ITC', 'FY2025',
 27.40, 7.20, 18.50, 28.40, 37.80, 0.00,
 2.85, 2.10, 3.15, 84.00,
 8, 8.10, 'Safe',
 0.7654, 1.0000, 0.3501, 0.8193, 1.2935)
ON CONFLICT (id) DO NOTHING;

-- Insert Forensic Red Flags
INSERT INTO red_flags (
    id, company_id, ticker, title, severity, category,
    description, evidence_quote, source_document, source_page,
    potential_impact, suggested_investigation
) VALUES
('rf-bel-01', 'comp-bel', 'BEL', 'Single-Customer MoD Procurement Cycle Risk', 'High', 'Customer & Supply Chain',
 'Over 82% of BEL revenue is generated from Indian Ministry of Defence (MoD) contracts. Any delay in government budget allocation or procurement clearance can stall milestone billings.',
 'A major portion of our supplies are to the Indian Defence Services. The procurement cycle involves extensive field trials and multiple approvals.',
 'BEL Integrated Annual Report FY2024', 64,
 'Lumpiness in quarterly revenue and working capital lockup.',
 'Audit order backlog delivery timelines and diversification into civilian space radars.'),
('rf-bel-02', 'comp-bel', 'BEL', 'Receivable Collection Cycle Stretch', 'Medium', 'Working Capital',
 'Trade receivables include balances from defence undertakings aggregating to 7,600 crore with debtor collection days at ~116 days.',
 'Trade receivables include unbilled dues from defense public undertakings awaiting final testing sign-off.',
 'BEL Annual Report FY2025', 148,
 'Working capital strain during intensive production cycles.',
 'Monitor cash conversion cycles and milestone inspection clearances.'),
('rf-reliance-01', 'comp-reliance', 'RELIANCE', 'High Consolidated Debt & Heavy Capital Intensity', 'High', 'Solvency & Debt',
 'Total debt stands at 3,18,000 Cr with annual capital expenditures of 1,22,000 Cr across 5G standalone networks and retail infrastructure.',
 'Consolidated capital expenditure for the year was 1,22,000 crore. Outstanding gross debt was 3,18,000 crore.',
 'RIL Integrated Annual Report FY2024', 246,
 'Higher interest obligations if new business monetisation lags schedule.',
 'Monitor EBITDA to interest coverage ratio and consumer IPO timelines.'),
('rf-titan-01', 'comp-titan', 'TITAN', 'Gold Metal Lease Liabilities & Bullion Price Spikes', 'High', 'Solvency & Debt',
 'Gold inventory of 20,500 Cr is primarily funded via Gold Metal Loans (GML), exposing Titan to gold price volatility and customs duty changes.',
 'Gold on lease arrangements are subject to price variations and interest rate fluctuations upon maturity.',
 'Titan Annual Report FY2024', 164,
 'Working capital strain and short-term gross margin fluctuations.',
 'Track hedging ratios on bullion leases and same-store sales growth.')
ON CONFLICT (id) DO NOTHING;

-- Insert Compiled Institutional Reports
INSERT INTO generated_reports (
    id, company_id, ticker, fiscal_year, title, analyst_rating, target_price_inr,
    executive_summary, financial_performance_summary, ratio_analysis_summary, red_flag_audit_summary, research_conclusion
) VALUES
('rep-bel-2025', 'comp-bel', 'BEL', 'FY2025',
 'Institutional Equity Research: Bharat Electronics Limited (NSE: BEL)',
 'Overweight / Buy', 345.00,
 'BEL is India premier defense electronics Navratna PSU, delivering revenue of 23,850 crore (+17.7% YoY) and Net Profit of 4,820 crore in FY25. Fortress zero-debt balance sheet and 78,500 Cr order book.',
 'Revenue expanded to 23,850 Cr, yielding Free Cash Flow of 4,500 Cr and operating margin of 25.41%.',
 'Current ratio stands at 2.32x with zero debt. ROE of 23.40% and ROCE of 27.05%. Piotroski score is 8/9.',
 'MoD dependency (>80% of sales) and milestone testing payment cycles remain the primary operational monitorables.',
 'Strong multi-year order visibility (~3.3 years) and expanding defense exports justify premium valuation.')
ON CONFLICT (id) DO NOTHING;


-- ------------------------------------------------------------------------------
-- PART 3: ESSENTIAL INSTITUTIONAL ANALYST SQL QUERIES
-- (Execute these in any SQL Workbench, Cloud SQL, or MongoDB Compass SQL Tool)
-- ------------------------------------------------------------------------------

-- QUERY 1: CORPORATE COVERAGE UNIVERSE OVERVIEW
SELECT 
    c.ticker,
    c.name,
    c.sector,
    c.currency,
    f.fiscal_year,
    f.revenue AS revenue_cr,
    f.net_income AS pat_cr,
    f.operating_margin_pct,
    f.free_cash_flow AS fcf_cr,
    f.total_debt AS debt_cr,
    r.roe_pct,
    r.piotroski_f_score,
    r.altman_z_score,
    r.altman_zone
FROM companies c
LEFT JOIN financial_statements f ON c.id = f.company_id
LEFT JOIN financial_ratios r ON c.id = r.company_id
ORDER BY f.revenue DESC;

-- QUERY 2: DUPONT 3-FACTOR ROE DECOMPOSITION AUDIT
-- Formula: ROE = Net Profit Margin * Asset Turnover * Equity Multiplier
SELECT 
    c.ticker,
    c.name,
    f.fiscal_year,
    f.net_margin_pct AS "Net_Margin_%",
    ROUND(f.revenue / f.total_assets, 2) AS "Asset_Turnover_x",
    ROUND(f.total_assets / f.shareholders_equity, 2) AS "Financial_Leverage_x",
    r.roe_pct AS "Reported_ROE_%",
    ROUND((f.net_margin_pct / 100.0) * (f.revenue / f.total_assets) * (f.total_assets / f.shareholders_equity) * 100, 2) AS "Calculated_DuPont_ROE_%"
FROM companies c
JOIN financial_statements f ON c.id = f.company_id
JOIN financial_ratios r ON c.id = r.company_id
ORDER BY r.roe_pct DESC;

-- QUERY 3: PIOTROSKI F-SCORE FUNDAMENTAL QUALITY AUDIT
-- Evaluates companies with scores >= 7 (Institutional Grade)
SELECT 
    c.ticker,
    c.name,
    r.piotroski_f_score,
    CASE 
        WHEN r.piotroski_f_score >= 8 THEN 'Very Strong (Top Tier)'
        WHEN r.piotroski_f_score = 7 THEN 'Strong Institutional'
        WHEN r.piotroski_f_score BETWEEN 5 AND 6 THEN 'Moderate / Stable'
        ELSE 'Weak / Fundamental Red Flag'
    END AS fundamental_classification,
    f.operating_cash_flow,
    f.net_income,
    CASE 
        WHEN f.operating_cash_flow > f.net_income THEN 'Healthy (Accruals Safe)'
        ELSE 'Warning (Accruals Exceed CFO)'
    END AS earnings_quality
FROM companies c
JOIN financial_ratios r ON c.id = r.company_id
JOIN financial_statements f ON c.id = f.company_id
ORDER BY r.piotroski_f_score DESC;

-- QUERY 4: ALTMAN Z-SCORE SOLVENCY & BANKRUPTCY RISK CLASSIFICATION
SELECT 
    c.ticker,
    c.name,
    r.altman_z_score,
    r.altman_zone,
    f.cash_and_equivalents AS cash_cr,
    f.total_debt AS debt_cr,
    r.debt_to_equity,
    r.current_ratio
FROM companies c
JOIN financial_ratios r ON c.id = r.company_id
JOIN financial_statements f ON c.id = f.company_id
ORDER BY r.altman_z_score DESC;

-- QUERY 5: HIGH-PRIORITY FORENSIC RED FLAGS DETECTED BY RED FLAG AGENT
SELECT 
    rf.ticker,
    c.name,
    rf.severity,
    rf.category,
    rf.title,
    rf.source_document,
    rf.source_page,
    rf.evidence_quote,
    rf.potential_impact
FROM red_flags rf
JOIN companies c ON rf.ticker = c.ticker
WHERE rf.severity = 'High'
ORDER BY rf.ticker;

-- QUERY 6: CASH FLOW ACCRUAL DIVERGENCE (EARNINGS MANIPULATION CHECK)
-- Checks if Net Income is backed by real Cash Flow from Operations
SELECT 
    c.ticker,
    c.name,
    f.net_income AS reported_pat_cr,
    f.operating_cash_flow AS ocf_cr,
    ROUND((f.operating_cash_flow / f.net_income) * 100, 1) AS "OCF_to_PAT_Conversion_%",
    f.capital_expenditure AS capex_cr,
    f.free_cash_flow AS fcf_cr,
    CASE 
        WHEN f.operating_cash_flow >= f.net_income THEN 'Pristine Cash Conversion'
        WHEN f.operating_cash_flow >= f.net_income * 0.7 THEN 'Acceptable Accrual Buffer'
        ELSE 'Aggressive Accrual Risk'
    END AS accrual_audit
FROM companies c
JOIN financial_statements f ON c.id = f.company_id
ORDER BY (f.operating_cash_flow / f.net_income) DESC;

-- QUERY 7: ORDER BOOK REVENUE VISIBILITY & DEFENSE BACKLOG
SELECT 
    c.ticker,
    c.name,
    f.revenue AS annual_turnover_cr,
    f.order_book AS unexecuted_order_book_cr,
    ROUND(f.order_book / f.revenue, 2) AS "Order_Book_to_Sales_Multiple",
    ROUND((f.order_book / f.revenue) * 12, 1) AS "Revenue_Visibility_Months"
FROM companies c
JOIN financial_statements f ON c.id = f.company_id
WHERE f.order_book IS NOT NULL;

-- QUERY 8: CROSS-COMPANY PEER BENCHMARKING (BEL vs RELIANCE vs TITAN vs ITC)
SELECT 
    c.ticker,
    c.name,
    f.revenue AS revenue_cr,
    f.revenue_growth_pct AS "YoY_Growth_%",
    f.operating_margin_pct AS "EBIT_Margin_%",
    f.net_margin_pct AS "PAT_Margin_%",
    r.roe_pct AS "ROE_%",
    r.roce_pct AS "ROCE_%",
    f.total_debt AS debt_cr,
    r.debt_to_equity AS "D/E",
    r.piotroski_f_score AS "Piotroski",
    r.altman_z_score AS "Altman_Z"
FROM companies c
JOIN financial_statements f ON c.id = f.company_id
JOIN financial_ratios r ON c.id = r.company_id
ORDER BY f.revenue_growth_pct DESC;

-- QUERY 9: STATUTORY SOURCE CITATION RETRIEVAL FOR RESEARCH AGENT
-- Used by Research Agent to retrieve audited citations for RAG verification
SELECT 
    dc.ticker,
    dc.fiscal_year,
    dc.page_number,
    dc.section,
    SUBSTRING(dc.content FROM 1 FOR 150) || '...' AS text_excerpt
FROM document_chunks dc
WHERE dc.ticker = 'BEL' AND dc.page_number IN (140, 48, 64)
ORDER BY dc.page_number;

-- QUERY 10: USER CREDENTIALS & ADMIN GATEWAY VERIFICATION
SELECT 
    id,
    email,
    name,
    role,
    institution,
    is_admin,
    status
FROM users
ORDER BY is_admin DESC, created_at ASC;
