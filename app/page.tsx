import { AuthButton } from "@/components/auth-button";
import { EnvVarWarning } from "@/components/env-var-warning";
import { ThemeSwitcher } from "@/components/theme-switcher";
import { hasEnvVars } from "@/lib/utils";
import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen flex flex-col">
      <nav className="w-full flex justify-center border-b border-b-foreground/10 h-16">
        <div className="w-full max-w-5xl flex justify-between items-center p-3 px-5 text-sm">
          <div className="flex gap-5 items-center font-semibold">
            <Link href={"/"}>Aso Karate 2</Link>
             
          </div>
          {!hasEnvVars ? <EnvVarWarning /> : <AuthButton />}
           <ThemeSwitcher />
        </div>
       
      </nav>
      
      <div className="flex-1 flex items-center justify-center">
        <div className="text-center space-y-6">
          <h1 className="text-6xl font-bold text-gray-300">🚧</h1>
          <h2 className="text-3xl font-bold text-gray-700">Sitio en Construcción</h2>
          <p className="text-lg text-gray-500 max-w-md">
            Estamos trabajando duro para traerte algo increíble. 
            ¡Vuelve pronto!
          </p>
          <div className="animate-pulse">
            <div className="h-2 bg-gray-200 rounded-full w-64 mx-auto"></div>
          </div>
        </div>
      </div>
      
        <footer className="w-full flex items-center justify-center border-t mx-auto text-center text-xs py-16">
          <h1 className="text-lg text-gray-600 dark:text-gray-400">
            Desarrollado Por el Equipo Dinamita .. <span className="font-semibold text-gray-800 dark:text-gray-200">Desarrollo de Aplicaciones 2</span> {" "}
            {/** <a
              href="https://supabase.com/?utm_source=create-next-app&utm_medium=template&utm_term=nextjs"
              target="_blank"
              className="font-bold hover:underline"
              rel="noreferrer"
            >
              Supabase
            </a>*/}
          </h1>
        </footer>
    </main>
  );
}
