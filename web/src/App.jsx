import { useEffect, useState } from "react";

function App() {
  const [health, setHealth] = useState(null);
  const [version, setVersion] = useState(null);
  const [name, setName] = useState(null);

  useEffect(() => {
    fetch("/api/name")
      .then(res => res.json())
      .then(data => setName(data.name))
      .catch(() => setName("ERROR"));

    fetch("/api/health")
      .then(res => res.json())
      .then(data => setHealth(data.status))
      .catch(() => setHealth("ERROR"));

    fetch("/api/version")
      .then(res => res.json())
      .then(data => setVersion(data.version))
      .catch(() => setVersion("ERROR"));
  }, []);

  // Show loading screen ONLY while data is null (not loaded)
  const isLoading = name === null || health === null || version === null;

  if (isLoading) {
    return (
      <div style={{ padding: 40, textAlign: "center" }}>
        <h1>Loading backend data…</h1>
        <div style={{
          marginTop: 20,
          fontSize: 18,
          opacity: 0.7
        }}>
          Please wait…
        </div>
      </div>
    );
  }

  // If loading finished → show data
  return (
    <div style={{ padding: 40 }}>
      <h1>Frontend → Backend Test via Ingress</h1>
      <h2>{name} Cluster: Backend data loaded</h2>
      <p><b>Health:</b> {health}</p>
      <p><b>Version:</b> {version}</p>
    </div>
  );
}

export default App;
