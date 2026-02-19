const express = require("express");
const path = require("path");
const cors = require("cors");
const bodyParser = require("body-parser");

const { runDailyGenerator, runBulkGenerator, buildRobotsAndSitemap } = require("./worker");
const api = require("./api");

const app = express();
app.use(cors());
app.use(bodyParser.json({ limit: "1mb" }));

app.use(express.static(path.join(__dirname, "..", "public")));
app.use("/generated", express.static(path.join(__dirname, "..", "generated")));
app.use("/api", api);

app.get("/health", (req, res) => res.json({ ok: true, ts: Date.now() }));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "..", "public", "index.html"));
});

// manual diário
app.post("/admin/generate", async (req, res) => {
  try {
    const result = await runDailyGenerator({ manual: true, baseUrl: process.env.BASE_URL || "" });
    res.json({ ok: true, result });
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e) });
  }
});

// 1 clique: bulk
app.post("/admin/generate-bulk", async (req, res) => {
  try {
    const n = Number(req.query.n || 30);
    const niche = String(req.query.niche || "auto");
    const result = await runBulkGenerator({ n, niche, baseUrl: process.env.BASE_URL || "" });
    res.json({ ok: true, result });
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e) });
  }
});

// rebuild seo
app.post("/admin/rebuild-seo", async (req, res) => {
  try {
    buildRobotsAndSitemap({ baseUrl: process.env.BASE_URL || "" });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: String(e) });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("✅ Server ON:", "http://localhost:" + PORT);
});
