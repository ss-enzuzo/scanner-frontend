"use client";

import { useState } from "react";

type Status =
  | { type: "idle" }
  | { type: "loading" }
  | { type: "success"; email: string }
  | { type: "error"; message: string };

export default function ScanForm() {
  const [url, setUrl] = useState("");
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<Status>({ type: "idle" });

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus({ type: "loading" });

    const params = new URLSearchParams({ url, email });

    try {
      const res = await fetch(`/api/scan?${params}`);
      if (res.ok) {
        setStatus({ type: "success", email });
      } else {
        const body = await res.text().catch(() => "");
        setStatus({
          type: "error",
          message: `Server returned ${res.status}${body ? ": " + body : ""}`,
        });
      }
    } catch (err) {
      setStatus({
        type: "error",
        message: `Could not reach scanner proxy — is it running? (${(err as Error).message})`,
      });
    }
  }

  const loading = status.type === "loading";

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4" style={{ fontFamily: "var(--font-inter)" }}>
      <div className="flex flex-col gap-1.5">
        <label htmlFor="url" className="text-xs font-medium" style={{ color: "rgba(255,255,255,0.7)" }}>
          Website URL
        </label>
        <input
          id="url"
          type="url"
          required
          placeholder="https://example.com"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          className="rounded-lg px-3 py-2.5 text-sm outline-none bg-white/10 text-white placeholder:text-white/30 border border-white/20 focus:border-[#23DC64] transition"
        />
      </div>

      <div className="flex flex-col gap-1.5">
        <label htmlFor="email" className="text-xs font-medium" style={{ color: "rgba(255,255,255,0.7)" }}>
          Email address
        </label>
        <input
          id="email"
          type="email"
          required
          placeholder="you@example.com"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="rounded-lg px-3 py-2.5 text-sm outline-none bg-white/10 text-white placeholder:text-white/30 border border-white/20 focus:border-[#23DC64] transition"
        />
      </div>

      <button
        type="submit"
        disabled={loading}
        className="mt-2 rounded-lg px-4 py-3 text-sm font-semibold transition disabled:opacity-50 disabled:cursor-not-allowed"
        style={{ background: "#23DC64", color: "#002F2F" }}
      >
        {loading ? "Starting scan…" : "Start scan"}
      </button>

      {status.type === "success" && (
        <p className="rounded-lg px-4 py-3 text-sm" style={{ background: "rgba(35,220,100,0.15)", color: "#23DC64" }}>
          Scan started — results will be sent to <strong>{status.email}</strong>.
        </p>
      )}

      {status.type === "error" && (
        <p className="rounded-lg px-4 py-3 text-sm" style={{ background: "rgba(255,100,100,0.15)", color: "#ff6b6b" }}>
          {status.message}
        </p>
      )}
    </form>
  );
}
