# FinSight AI – Multi-Agent Financial Research System

FinSight AI is an institutional-grade, multi-agent financial research and forensic accounting platform. It automates the parsing, financial ratio modeling, forensic anomaly scanning, and investment report generation for audited corporate Annual Reports and SEC Form 10-K filings.

The system is recreated from the ground up using **React.js (JavaScript & JSX)**, **Python FastAPI**, **MongoDB Community Server & Compass**, **Pandas & NumPy**, and **Python ReportLab**.

---

## 1. System Architecture & Tech Stack

```
FinSight-AI/
├── frontend/             # React.js SPA (JavaScript & JSX only, Tailwind CSS, Recharts, Lucide React)
│   ├── src/
│   │   ├── components/   # Common, layout, charts, agents
│   │   ├── pages/        # Index, Login, Dashboard, Workspace, Documents, Financials, etc.
│   │   ├── services/     # Axios API client (api.js)
│   │   ├── context/      # AuthContext.jsx
│   │   └── utils/        # PDF trigger and helpers
├── backend/              # Python FastAPI REST API Backend
│   ├── app/
│   │   ├── api/          # 16 REST API Routers (/api/auth, /api/dashboard, /api/ratios...)
│   │   ├── core/         # Config, JWT authentication, Security dependencies
│   │   ├── database/     # MongoDB Community Server PyMongo client & collection seeders
│   │   ├── agents/       # 5 Autonomous AI Agents & Central Orchestrator
│   │   ├── analytics/    # Pandas & NumPy Financial Ratio Engine (DuPont, Piotroski, Altman Z)
│   │   ├── rag/          # Semantic RAG retrieval & Gemini AI client
│   │   └── reports/      # Python ReportLab 13-Section PDF generator
└── README.md
```

### Technology Highlights

- **Frontend:** React 19, JavaScript ES6+, JSX, Tailwind CSS, Axios, Recharts, Lucide React icons.
- **Backend:** Python 3.10+, FastAPI, Pydantic v2, Uvicorn, PyMongo.
- **Database:** MongoDB Community Server (`mongodb://localhost:27017/`), managed with **MongoDB Compass**.
- **Financial Analytics:** Pandas & NumPy for financial statement computations, 10 core ratios, DuPont 3-stage ROE analysis, Piotroski F-Score (9 points), Altman Z-Score, and Beneish M-Score.
- **AI & RAG:** Google Gemini 3.8 Flash with Retrieval-Augmented Generation (RAG) and zero-hallucination citation boundaries.
- **PDF Export:** Python ReportLab compiling downloadable, publication-grade 13-section equity research PDF reports.

---

## 2. The 6 Autonomous Multi-Agent AI Architecture

FinSight AI coordinates 6 specialized AI micro-agents via a central orchestrator:

1. **Document Agent (`document_agent.py`):**
   Handles document upload, parsing, chunking, embedding generation, and vector database indexing into MongoDB.
2. **Extraction Agent (`ratio_engine.py`):**
   Pulls key financial metrics, ratios, and performance numbers from indexed documents using Pandas & NumPy, computing DuPont 3-stage ROE, Piotroski F-Score (9 points), and Altman Z-Score.
3. **Red Flag Agent (`forensic_agent.py`):**
   Scans for anomalies, rising debt, falling margins, auditor qualifications, and unusual financial patterns across Critical, High, Medium, and Low severity tiers.
4. **Comparison Agent (`comparison_agent.py`):**
   Cross-references financial data across multiple companies for benchmarking and peer analysis, normalizing multi-year reporting periods.
5. **Research Agent (`rag_agent.py`):**
   Handles user queries using multi-step retrieval and reasoning with strict source citation powered by Google Gemini 3.8 Flash, strictly prohibiting synthetic extrapolation.
6. **Report Agent (`synthesis_agent.py` & `pdf_generator.py`):**
   Compiles outputs from all agents into a structured analyst-style research report exportable as a professional ReportLab PDF.

---

## 3. MongoDB Community Server & Compass Setup

### Connection Details
- **MongoDB Connection URL:** `mongodb://localhost:27017/`
- **Database Name:** `finsight_db`
- **Graphical Tool:** **MongoDB Compass**

### Step-by-Step MongoDB Compass Guide:
1. Download and install [MongoDB Community Server](https://www.mongodb.com/try/download/community) and [MongoDB Compass](https://www.mongodb.com/try/download/compass).
2. Open MongoDB Compass.
3. In the "New Connection" screen, enter the URI: `mongodb://localhost:27017/` and click **Connect**.
4. The database `finsight_db` will automatically appear with all 15 initialized collections:
   - `users`
   - `companies`
   - `documents`
   - `document_chunks`
   - `financial_statements`
   - `financial_ratios`
   - `red_flags`
   - `research_sessions`
   - `chat_conversations`
   - `chat_messages`
   - `generated_reports`
   - `citations`
   - `agent_logs`
   - `user_activity`
   - `embeddings`

---

## 4. Windows 11 Local Execution Instructions

### A. Prerequisites
- Python 3.10 or higher
- Node.js 18 or higher & npm
- MongoDB Community Server & MongoDB Compass

---

### B. Backend Setup (FastAPI + PyMongo)

1. Open PowerShell or Command Prompt on Windows 11:
```powershell
cd backend
```

2. Create and activate a Python virtual environment:
```powershell
python -m venv venv
venv\Scripts\Activate.ps1
```

3. Install required Python packages:
```powershell
pip install -r requirements.txt
```

4. Configure environment variables in `backend/.env` (or set directly):
```powershell
# Copy template
copy ..\.env.example .env
```
*(Add your Gemini API key under `GEMINI_API_KEY` from https://aistudio.google.com/app/apikey)*

5. Start the FastAPI backend server:
```powershell
uvicorn app.main:app --reload --port 8000
```

- **Backend API:** `http://localhost:8000`
- **Interactive OpenAPI Documentation:** `http://localhost:8000/docs`
- **Health Check Endpoint:** `http://localhost:8000/api/health`

---

### C. Frontend Setup (React.js JSX)

1. Open a new PowerShell terminal:
```powershell
cd frontend
```

2. Install npm dependencies:
```powershell
npm install
```

3. Launch the Vite development server:
```powershell
npm run dev
```

- **Frontend URL:** `http://localhost:5173`

### Quick start from the repository root

After MongoDB Community Server is running and Python dependencies are installed, you can start the backend and the main Vite app together from the repository root:

```powershell
npm run dev:all
```

The app is available at `http://localhost:3000`; the Vite `/api` proxy forwards requests to FastAPI on port `8000`. Check `http://localhost:8000/api/health` before registering. The health endpoint returns HTTP 503 with `"status": "degraded"` when MongoDB is not connected; registration and user management require MongoDB and will not save users to browser storage.

---

## 5. Pre-Configured Accounts for Demonstration

| Account Type | Email | Password | Role & Access |
|---|---|---|---|
| **Super Administrator** | `admin@gmail.com` | `admin@123` | Full access to Admin Console, User Directory, Diagnostics, and Vector Collections |
| **Senior Equity Analyst** | `rohithv3009@gmail.com` | `RohithFinSight@2025` | Full access to financial models, RAG chat, comparison, and PDF report exports |
| **Custom Registration** | *Any email* | *User password* | Use the "Register" tab to create custom analyst accounts |

---

## 6. Pre-Loaded Bluechip Corporate Coverage (FY23–FY25)

The database includes multi-year audited financial statements for premier corporations:
- **BEL (Bharat Electronics Limited):** Defence electronics Navratna PSU (₹23,850 Cr revenue, ₹78,500 Cr order backlog, zero debt).
- **HCLTECH (HCL Technologies):** IT services & software products (₹1,19,400 Cr revenue, 18.6% operating margin).
- **RELIANCE (Reliance Industries):** Conglomerate, Jio 5G & Retail (₹9,94,500 Cr revenue, ₹1,98,000 Cr EBITDA).
- **TITAN (Titan Company):** Branded jewelry & luxury (₹56,800 Cr revenue, 31% ROE).
- **ITC (ITC Limited):** FMCG & agri-business (₹83,400 Cr revenue, 37% operating margin).
- **TCS (Tata Consultancy Services):** Global IT benchmark (₹2,58,200 Cr revenue, 51.6% ROE).
- **TATAMOTORS (Tata Motors):** Passenger EVs & JLR turnaround (₹4,78,000 Cr revenue).

---

## 7. ReportLab PDF Generation

Clicking **"Download PDF (ReportLab)"** compiles a multi-page institutional report adhering to institutional standards:
- Professional header and footer with dynamic page numbering (`NumberedCanvas`)
- Strict source citations referencing statutory report page numbers
- Formatted financial metrics tables with multi-year comparisons
- Complete 13 structured analytical sections
