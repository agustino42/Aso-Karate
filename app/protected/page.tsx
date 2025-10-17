import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export default async function ProtectedPage() {
  const supabase = await createClient();

  const { data, error } = await supabase.auth.getClaims();
  if (error || !data?.claims) {
    redirect("/auth/login");
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center">
      <div className="text-center space-y-6">
        <h1 className="text-6xl font-bold text-gray-300">🔒</h1>
        <h2 className="text-3xl font-bold text-gray-700">Área Protegida en Construcción</h2>
        <p className="text-lg text-gray-500 max-w-md">
          Esta sección está siendo desarrollada especialmente para usuarios autenticados.
          ¡Pronto estará disponible!
        </p>
        <div className="bg-green-100 text-green-800 px-4 py-2 rounded-lg">
          ✓ Usuario autenticado correctamente
        </div>
        <div className="animate-pulse">
          <div className="h-2 bg-gray-200 rounded-full w-64 mx-auto"></div>
        </div>
      </div>
    </div>
  );
}
