import React, { useState } from 'react';

export default function App() {
  const [message, setMessage] = useState("");

  const fetchBackend = async () => {
    try {
      const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:3000";
      const res = await fetch(`${apiUrl}/api/hello`);
      const data = await res.json();
      setMessage(data.message);
    } catch (err) {
      setMessage("Error connecting to backend");
    }
  };

  return (
    <div style={{ padding: 20 }}>
      <h1>Frontend Connected to Backend</h1>
      <button onClick={fetchBackend}>Fetch Backend</button>
      <p>{message}</p>
    </div>
  );
}
