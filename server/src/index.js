const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for Ingress
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

// Routes - NO /api prefix here (Ingress adds it)
app.get("/name", (req, res) => {
  res.json({ name: "Ammar" });
});

app.get("/health", (req, res) => {
  res.json({ status: "healthy" });
});

app.get("/version", (req, res) => {
  res.json({ version: "1.0.0" });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend running on port ${PORT}`);
});