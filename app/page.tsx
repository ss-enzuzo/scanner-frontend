import ScanForm from "./components/ScanForm";

export default function Home() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 px-4">
      <div className="w-full max-w-md rounded-2xl bg-white p-8 shadow-sm ring-1 ring-zinc-200">
        <h1 className="mb-1 text-xl font-semibold text-zinc-900">
          Website Scanner
        </h1>
        <p className="mb-6 text-sm text-zinc-500">
          Enter a URL and your email to receive the scan results.
        </p>
        <ScanForm />
      </div>
    </div>
  );
}
