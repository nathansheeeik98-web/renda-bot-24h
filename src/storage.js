const fs = require("fs");
const path = require("path");

function ensureDir(p){
  const dir = path.dirname(p);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function readJSON(filePath, fallback){
  try{
    if (!fs.existsSync(filePath)) return fallback;
    const raw = fs.readFileSync(filePath, "utf-8");
    return JSON.parse(raw);
  }catch(e){
    return fallback;
  }
}

function writeJSON(filePath, obj){
  ensureDir(filePath);
  fs.writeFileSync(filePath, JSON.stringify(obj, null, 2), "utf-8");
}

module.exports = { readJSON, writeJSON };
