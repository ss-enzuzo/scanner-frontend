import { NextRequest, NextResponse } from "next/server";

const PROXY_BASE = process.env.PROXY_URL ?? "http://localhost:3000";
const PROXY_TOKEN = process.env.PROXY_TOKEN ?? "mysecret";

export async function GET(req: NextRequest) {
  const { searchParams } = req.nextUrl;
  const url = searchParams.get("url");

  if (!url) {
    return NextResponse.json({ error: "url is required" }, { status: 400 });
  }

  const params = new URLSearchParams({ url });
  const upstream = `${PROXY_BASE}/scan?${params}`;

  try {
    const res = await fetch(upstream, {
      method: "POST",
      headers: { Authorization: `Bearer ${PROXY_TOKEN}` },
    });
    const body = await res.text().catch(() => "");
    return new NextResponse(body, { status: res.status });
  } catch (err) {
    return NextResponse.json(
      { error: `Could not reach scanner proxy: ${(err as Error).message}` },
      { status: 502 }
    );
  }
}
