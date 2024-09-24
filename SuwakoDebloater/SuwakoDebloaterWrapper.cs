// SuwakoDebloater - Executable wrapper that launches the main script with just a click - (c) Bionic Butter

using System;
using System.Diagnostics;
using System.IO;

class Program
{
	static void Main(string[] args)
	{
		string exeDirectory = AppDomain.CurrentDomain.BaseDirectory;
		string scriptPath = Path.Combine(exeDirectory, "SuwakoDebloater.ps1");
	
		// Check if the script exists
		if (!File.Exists(scriptPath)) {
			Console.WriteLine("ERROR: The associated script is not found");
			return;
		}
	
		// Create a new process to run PowerShell
		ProcessStartInfo startInfo = new ProcessStartInfo() {
			FileName = "powershell.exe",
			Arguments = string.Format("-ExecutionPolicy Bypass -Command \"& '{0}'\"", scriptPath),
			UseShellExecute = false,
			CreateNoWindow = false
		};
	
		using (Process process = new Process()) {
			process.StartInfo = startInfo;
			process.Start();
		}
	}
}
