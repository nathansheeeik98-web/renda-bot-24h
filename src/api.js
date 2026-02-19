const express = require("express");
const router = express.Router();
const { simulateIncome, generateIdeas } = require("./logic");
const { readJSON, writeJSON } = require("./storage");

router.post("/simulate", (req, res) => {
  const out = simulateIncome(req.body || {});
  res.json(out);
});

router.post("/ideas", (req, res) => {
  const out = generateIdeas(req.body || {});
  res.json(out);
});

router.post("/hit", (req, res) => {
  const db = readJSON("data/stats.json", { hits: 0, byDay: {} });
  db.hits += 1;
  const d = new Date();
  const key = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,"0")}-${String(d.getDate()).padStart(2,"0")}`;
  db.byDay[key] = (db.byDay[key] || 0) + 1;
  writeJSON("data/stats.json", db);
  res.json({ ok: true, hits: db.hits, today: db.byDay[key] });
});

router.get("/stats", (req, res) => {
  const db = readJSON("data/stats.json", { hits: 0, byDay: {} });
  res.json(db);
});

module.exports = router;
