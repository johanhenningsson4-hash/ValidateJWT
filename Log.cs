
#define DEBUG_LOGGING_ENABLED

using System;
using System.Diagnostics;
using System.IO;

namespace TPDotnet.MTR.Sweden.TechServices
{
    public static class Log
    {
        #region Constructor

        static Log()
        {
            threadlock = new object();
        }

        #endregion

        #region Public methods

        public struct LogFile
        {
            public const string Prefix = "wn_swedbank_eft";
            public const string Extension = "log";
            public const double DaysToKeep = 10.0;
        }

        public struct TransactionLogFile
        {
            public const string Prefix = "wn_swedbank_eft_transaction_logs";
            public const string Extension = "log";
        }

        public enum LogLevel
        {
            OFF = 0,
            INFO = 1,
            WARNING = 2,
            ERROR = 3,
            DEBUG = 4,
            TRACE = 5
        }

        public static string FullFileName
        {
            get
            {
                string datePostfix = DateTime.Now.ToString("yyyyMMdd");
                string logFileName = string.Format("{0}_{1}.{2}", LogFile.Prefix, datePostfix, LogFile.Extension);
                string fullFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, logFileName);
                return fullFileName;
            }
        }

        public static string FullTransactionLogFileName
        {
            get
            {
                string datePostfix = DateTime.Now.ToString("yyyyMMdd");
                string logFileName = string.Format("{0}_{1}.{2}", TransactionLogFile.Prefix, datePostfix, TransactionLogFile.Extension);
                string fullFileName = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, logFileName);
                return fullFileName;
            }
        }

        public static void WriteDebug(string text)
        {
#if DEBUG_LOGGING_ENABLED

            lock (threadlock)
            {
                CleanOldLogFiles();
                File.AppendAllText(Log.FullFileName, LogFormattedText(text, LogLevel.DEBUG));
            }
#endif
        }

        public static void Write(string text)
        {
            lock (threadlock)
            {
                CleanOldLogFiles();
                File.AppendAllText(Log.FullFileName, LogFormattedText(text, LogLevel.INFO));
            }
        }

        public static void WriteError(string text)
        {
            WriteError(text, null);
        }

        public static void WriteError(string text, Exception ex)
        {
            lock (threadlock)
            {
                CleanOldLogFiles();
                File.AppendAllText(Log.FullFileName, Log.LogFormattedText(text, ex, LogLevel.ERROR));
            }
        }

        public static void CleanOldLogFiles()
        {
            string logDirectory = AppDomain.CurrentDomain.BaseDirectory;
            string searchPattern = string.Format("{0}*.{1}", LogFile.Prefix, LogFile.Extension);
            string[] logFiles = Directory.GetFiles(logDirectory, searchPattern, SearchOption.TopDirectoryOnly);
            DateTime now = DateTime.Now;
            foreach (string f in logFiles)
            {
                DateTime created = File.GetCreationTime(f);
                if ((now - created).TotalDays > LogFile.DaysToKeep)
                {
                    System.IO.File.Delete(f);
                }
            }
        }

        public static void WriteTransactionLogs(string transactionLogText)
        {
            lock (threadlock)
            {
                File.AppendAllText(Log.FullTransactionLogFileName, string.Format("{0}{1}{0}{2}{0}",
                    System.Environment.NewLine,
                    DateTime.Now,
                    transactionLogText));
            }
        }

        #endregion

        #region Private methods

        private static object threadlock;

        #endregion 

        #region Private helper methods

        private static string LogFormattedText(string text, LogLevel level)
        {
            return string.Format("{0}\t{1}\t{2}\t{3}{4}",
                DateTime.Now,
                level,
                CallerInfo(),
                TabbedText(text),
                System.Environment.NewLine);
        }

        private static string LogFormattedText(string text, Exception ex, LogLevel level)
        {
            if (ex == null)
            {
                return string.Format("{0}\t{1}\t{2}\t{3}{4}",
                    DateTime.Now,
                    level,
                    CallerInfo(),
                    TabbedText(text + ": "),
                    System.Environment.NewLine);
            }
            else
            {
                return string.Format("{0}\t{1}\t{2}\t{3}{4}",
                    DateTime.Now,
                    level,
                    CallerInfo(),
                    TabbedText(text + ": " + ex.ToString()),
                    System.Environment.NewLine);
            }
        }

        private static string TabbedText(string text)
        {
            string tabbedText = text.Replace(
                string.Format("{0}",
                    System.Environment.NewLine),
                        "\r\n").Replace("\r\n",
                            "\r\n\t\t\t");
            return tabbedText;
        }

        private static string CallerInfo()
        {
            string callerInfoText = string.Empty;
            try
            {
                StackFrame frame = new StackFrame(3);
                var method = frame.GetMethod(); // the hole method declaration with parameter types, not used
                var type = method.DeclaringType;
                var name = method.Name;
                callerInfoText = string.Format("{0}.{1}:", type, name);
            }
            catch (Exception)
            {
            }
            return callerInfoText;
        }

        #endregion
    }
}