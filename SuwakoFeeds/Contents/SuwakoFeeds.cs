// Suwako Feeds - Enables News and Interest on unsupported editions of updated Windows 10, version 2004 and later - (c) Bionic Butter
// To compile, either use Visual Studio and target .NET 4.8, or use the built in compiler:
// - C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /nologo /target:winexe /out:SuwakoFeeds.exe SuwakoFeeds.cs

using System;
using System.IO;
using System.Diagnostics;
using System.Management;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Win32;

class SuwakoFeeds {
	static StreamWriter writer;
	
	static void Main(string[] args) {
		// Set up logging and output the branding
		DateTime startTime = DateTime.Now;
		string logPath = "SuwakoFeeds.log";
		string seperator = new string('=', 120);
		
		writer = new StreamWriter(logPath, true);
		Console.SetOut(writer);
		
		Log(seperator);
		Log("Suwako Feeds - News and Interest on unsupported editions enabler");
		Log("Version 3.0 - (c) Bionic Butter\n");
		Log("Applicated started at {0}", startTime);
		
		// Sets the value right away on start
		EnableFeeds();
		
		// Start monitoring Explorer
		watchExplorer();
	
		// And then keep the app alive. Everything else will be handled asynchornously
		Application.Run(new HiddenContext());
	}
	
	static void Log(string message, params object[] args) {
		string formattedMessage = string.Format(message, args);
		Console.WriteLine(formattedMessage);
		writer.Flush(); // Ensure the buffer is flushed so the text appears in the file right away
	}

	static void watchExplorer()
	{
		Task.Run(() => {
			try
			{
				WqlEventQuery query = new WqlEventQuery("SELECT * FROM Win32_ProcessStartTrace WHERE ProcessName = 'explorer.exe'");
				ManagementEventWatcher watcher = new ManagementEventWatcher(query);
				watcher.EventArrived += async (sender, e) => {
					Log("Detected that Explorer has (re)started.");
					await RunAsyncFunction();
				};
				watcher.Start();
				Log("Started monitoring Explorer asynchornously.");
			}
			catch (Exception ex)
			{
				Log(ex.Message);
			}
		});
	}

	static bool isDesktopPresent() {
		foreach (var process in Process.GetProcessesByName("explorer")) {
			try {
				var mainWindowTitle = process.MainWindowTitle;
				if (string.IsNullOrEmpty(mainWindowTitle) || mainWindowTitle == "Program Manager") {return true;}
			}
			catch (Exception ex) {Log(ex.Message);}
		}
		return false;
	}

	static void EnableFeeds() {
		string keyName = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds";
		string valueName = "IsFeedsAvailable";
		try {
			using (RegistryKey key = Registry.CurrentUser.OpenSubKey(keyName, writable: true)) {
				if (key != null) {
					System.Threading.Thread.Sleep(1000);
					key.SetValue(valueName, 1, RegistryValueKind.DWord);
					Log("Successfully enabled Feeds.");
				}
			}
		}
		catch (Exception ex) {
			Log("Oh no! Couldn't set the registry value to enable Feeds.");
			Log("If you didn't remove UCPD prior to installing this, please do so. The error was:");
			Log(ex.Message);
		}
	}

	static async Task<bool> EnableFeedsAsync() {
		return await Task.Run(() => {
			Log("Within 60 seconds, force the 'IsFeedsAvailable' registry value to 1 until SearchApp.exe respawns");
			
			string keyName = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds";
			string valueName = "IsFeedsAvailable";
			bool status = false;
			string exStatus = "";
			int attempts = 0;
			const int maxAttempts = 60;
		
			try {
				while (attempts < maxAttempts) {
					Task.Delay(500).Wait();
					using (RegistryKey key = Registry.CurrentUser.OpenSubKey(keyName, writable: true)) {
						if (key != null) {
							key.SetValue(valueName, 1, RegistryValueKind.DWord);
							status = true;
						}
					}
		
					// Check if the SearchApp is up, and if so stop the loop
					if (Process.GetProcessesByName("SearchApp").Length > 0) {break;}
		
					// Wait for 1 second before the next iteration
					Task.Delay(500).Wait();
					attempts++;
				}
			}
			catch (Exception ex) {
				exStatus = ex.Message;
				status = false;
			}
		
			// If max attempts reached and process not found, return false
			if (attempts >= maxAttempts) {
				Log("Did Explorer fail to start? Aborting operation and waiting for the next restart.");
				return false;
			}
			
			if (status == false) {
				Log("Oh no! Couldn't set the registry value to enable Feeds.");
				Log("If you didn't remove UCPD prior to installing this, please do so. The error was:");
				Log(exStatus);
			} else {
				Log("Successfully enabled Feeds.");
			}
			return status;
		});
	}


	static async Task RunAsyncFunction() {
		if (isDesktopPresent()) {
			Log("Shell is up! Enabling Feeds...");
			bool didFeedsEnable = await EnableFeedsAsync();
			Log("Last asynchronous call status was: {0}\n", didFeedsEnable);
		}
	}
}

public class HiddenContext : ApplicationContext {
	public HiddenContext() {}
	
	protected override void Dispose(bool disposing) {
		// Clean up any resources
		base.Dispose(disposing);
	}
}
