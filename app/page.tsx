import ScanForm from "./components/ScanForm";

export default function Home() {
  return (
    <div className="min-h-screen bg-white flex flex-col items-center justify-center px-4">
      {/* Hero card */}
      <div className="w-full max-w-md rounded-[20px] bg-[#002F2F] px-8 py-10 shadow-lg">
        <h1
          className="text-2xl font-bold text-white mb-2"
          style={{ fontFamily: "var(--font-jakarta)" }}
        >
          Website Compliance Scanner
        </h1>
        <p
          className="text-sm mb-8"
          style={{ color: "rgba(255,255,255,0.6)", fontFamily: "var(--font-inter)" }}
        >
          Enter a URL and your email to receive the scan results.
        </p>

        <ScanForm />
      </div>

      {/* Footer */}
      <p
        className="mt-6 text-xs"
        style={{ color: "#aaaaaa", fontFamily: "var(--font-inter)" }}
      >
        Powered by{" "}
        <a
          href="https://www.enzuzo.com"
          target="_blank"
          rel="noopener noreferrer"
          className="font-medium hover:underline"
          style={{ color: "#002F2F" }}
        >
          Enzuzo
        </a>
      </p>
    </div>
  );
}
