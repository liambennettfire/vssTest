using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Diagnostics;
using System.Collections.Specialized;

namespace TM_Interface_Inbound
{
    class TM_Interface_Inbound
    {
        // .Config File settings
        static string source_type;  // xml, xmlflat, seff, sql, table, or file
        static string source_spec;  // name/text of: table, seff app_id, filename (delimited/fixed/xml), or quoted sql statement (e.g. "exec sproc" or "select ...")
        static string source_spec_part2;
        static string source_connect_str;
        static string interface_connect_str;
        static string interface_sproc_name;
        static string logfilelocation;
        static string tempfilelocation;

        static string interface_id;
        static string dtstamp = "";
        static string file_pathname;
        static string log_pathname;
        static TextWriter tw = null;

        [STAThread]   // required by SQLXMLBULKLOAD
        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Msg_Writer(2, "Must specify the job's Interface ID on the command-line - aborting the job");
                return;
            }

            try
            {
                dtstamp = TimeStamp_Formatted();

                interface_id = args[0];

                string error_msg = Get_ConfigFile_Parameters(interface_id);

                if (error_msg == null)
                {
                    if (source_type.StartsWith("xml"))
                    {
                        if (!File.Exists(source_spec))
                            error_msg = "Source file '" + Path.GetFullPath(source_spec) + "' not found";
                        else if (!File.Exists(source_spec_part2))
                            error_msg = "XML schema file '" + Path.GetFullPath(source_spec_part2) + "' not found";
                    }

                    if (source_type == "file")
                    {
                        if (!File.Exists(source_spec))
                            error_msg = "Source file '" + Path.GetFullPath(source_spec) + "' not found";
                    }
                }

                if (error_msg != null && error_msg.Length > 0)
                {
                    Msg_Writer(2, error_msg);
                    return;
                }


                if (tempfilelocation == null || tempfilelocation.Length == 0)
                    tempfilelocation = ".";
                else if (!Directory.Exists(tempfilelocation))
                {
                    Directory.CreateDirectory(tempfilelocation);  // create temp directory if it doesn't exist

                    if (!Directory.Exists(tempfilelocation))
                        tempfilelocation = ".";                   // config file had invalid dir name so use local dir (should be fatal error?)
                }


                if (source_type == "file")
                    file_pathname = Path.GetFullPath(source_spec);  // resolve to full path name
                else
                {
                    // Source is not an already-conforming file -> do the necessary pre-processing to get it there

                    if (source_type.StartsWith("xml"))   // XML file/format -> generate temporary intermediate data table(s) from it
                    {
                        Msg_Writer(1, "XML pre-process step started");

                        SQLXMLBULKLOADLib.SQLXMLBulkLoad4Class objBL = new SQLXMLBULKLOADLib.SQLXMLBulkLoad4Class();
                        //objBL.ConnectionString = "Provider=sqloledb;server=MONTY;database=UCAL_DEV;integrated security=SSPI";
                        objBL.ConnectionString = "Provider=sqloledb;" + interface_connect_str;  // "Provider=sqloledb;Data Source=MONTY;database=UCAL_DEV;User Id=qsidba;Password=qsidba";
                        objBL.BulkLoad = true;
                        objBL.ErrorLogFile = Path.GetFullPath(logfilelocation) + "\\" + "error.xml";
                        objBL.SchemaGen = false;     // doesn't produce desired table schema
                        objBL.SGDropTables = false;  // don't lose desired table schema
                        objBL.XMLFragment = true;    // no single root node, just a bunch of "new title" nodes
                        objBL.Execute(source_spec_part2, source_spec);

                        Msg_Writer(1, "XML pre-process step completed");
                    }

                    Msg_Writer(1, "Intermediate file pre-process step started");

                    string intermediate_filename = Path.GetFullPath(tempfilelocation) + "\\" + interface_id + ".txt";

                    Process preproc = new Process();

                    if (source_type == "table" || source_type == "sql" || source_type == "xmlflat")
                    {
                        // simpler data structure -> use simpler process to create interface input file

                        // parse source connection string and create a bcp-format connection parameters string
                        string conn_params = source_connect_str;
                        int i = conn_params.IndexOf("database",StringComparison.OrdinalIgnoreCase);
                        conn_params = ((i < 0) ? "" : source_connect_str.Remove(i))
                                    + ((conn_params.IndexOf(";",i+1) < 0) ? "" : conn_params.Substring(conn_params.IndexOf(";",i+1)+1));
                        conn_params = conn_params.Replace("Password", "-P").Replace("User ID", "-U").Replace("Data Source", "-S").Replace("=", " ").Replace(";", " ");

                        preproc.StartInfo.FileName = "bcp.exe";
                        preproc.StartInfo.Arguments = source_spec
                                                     + ((source_type == "sql") ? " queryout \"" : " out \"")
                                                     + intermediate_filename
                                                     + "\" -c "
                                                     + conn_params;
                    }
                    else  // one-to-many hierarchical data structure -> use more sophisticated process to create interface input file
                    {
                        // If source_type is xml, then the seff app_id is not configurable -> it is the same as the interface_id
                        string seff_app_id = (source_type == "seff") ? source_spec : interface_id;

                        preproc.StartInfo.FileName = "Hierarchical_Formatter.exe";
                        preproc.StartInfo.Arguments = seff_app_id;
                    }
                    preproc.StartInfo.UseShellExecute = false;
                    preproc.StartInfo.RedirectStandardOutput = true;
                    preproc.StartInfo.CreateNoWindow = true;

                    preproc.Start();
                    string proc_msg = preproc.StandardOutput.ReadToEnd();
                    if (proc_msg != null && proc_msg.Length > 0)
                        Msg_Writer(1, proc_msg);
                    preproc.WaitForExit();

                    if (!File.Exists(intermediate_filename))
                    {
                        Msg_Writer(2, "Intermediate file '" + intermediate_filename + "' does not exist - aborting the job...");
                        return;
                    }

                    Msg_Writer(1, "Intermediate file pre-process step completed");

                    file_pathname = intermediate_filename;
                }


                Msg_Writer(1, "Primary process started");

                Process_Job(file_pathname);

                Msg_Writer(1, "Primary process completed");
            }
            catch (Exception ex)
            {
                Msg_Writer(2, ex.ToString());
            }
            finally
            {
                if (tw != null)
                    tw.Close();
            }
        }

        private static void Process_Job(string input_filename)
        {
            int result_code;
            string result_msg = null;
            SqlConnection conn = null;

            try
            {
                // Register job start in qsijob tables --------------------------------------------

                conn = new SqlConnection(interface_connect_str);
                SqlCommand cmd = new SqlCommand("dbo.UpdFld_XVQ_QsiJob_Start", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sp_i_externalcode = new SqlParameter("@i_externalcode", SqlDbType.VarChar);
                SqlParameter sp_i_jobtypecode = new SqlParameter("@i_jobtypecode", SqlDbType.Int);
                SqlParameter sp_i_jobtypesubcode = new SqlParameter("@i_jobtypesubcode", SqlDbType.Int);
                SqlParameter sp_i_userid = new SqlParameter("@i_userid", SqlDbType.VarChar);
                SqlParameter sp_o_qsijobkey = new SqlParameter("@o_qsijobkey", SqlDbType.Int);
                SqlParameter sp_o_error_code = new SqlParameter("@o_error_code", SqlDbType.Int);
                SqlParameter sp_o_error_desc = new SqlParameter("@o_error_desc", SqlDbType.VarChar);

                sp_i_externalcode.Value = interface_id;      // ID of this interface (must exist in gentables.externalcode under tableid=543)
                sp_i_jobtypecode.Value = DBNull.Value;       // don't need to specify jobtypecode because we have interface ID
                sp_i_jobtypesubcode.Value = DBNull.Value;    // don't need to specify jobtypesubcode because we have interface ID
                sp_i_userid.Value = interface_id + "_Interface";
                sp_o_qsijobkey.Direction = ParameterDirection.Output;
                sp_o_error_code.Direction = ParameterDirection.Output;
                sp_o_error_desc.Direction = ParameterDirection.Output;

                sp_o_error_desc.Size = 2000;

                cmd.Parameters.Add(sp_i_externalcode);
                cmd.Parameters.Add(sp_i_jobtypecode);
                cmd.Parameters.Add(sp_i_jobtypesubcode);
                cmd.Parameters.Add(sp_i_userid);
                cmd.Parameters.Add(sp_o_qsijobkey);
                cmd.Parameters.Add(sp_o_error_code);
                cmd.Parameters.Add(sp_o_error_desc);

                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();

                if ((int)sp_o_error_code.Value < 0)
                {
                    // @o_error_code signifying missing job identifier, job already running, or
                    // dbo.write_qsijobmessage unable to read/write/access the qsijobmessages tables.

                    Msg_Writer(1, "Error while initiating QsiJob start (" + sp_o_error_desc.Value.ToString() + ") - aborting.");
                    return;
                }


                // Perform the job by iterating through the input file records --------------------

                int qsijobkey = (int)sp_o_qsijobkey.Value;

                int record_count = Process_File(input_filename, qsijobkey, out result_code, out result_msg);

                if (result_code < 2 && result_msg != null)  // (result_code < 2) = aborted on invalid data or system error
                {
                    Msg_Writer(2, result_msg);
                }


                // Register job end in qsijob tables ----------------------------------------------

                cmd.CommandText = "dbo.UpdFld_XVQ_QsiJob_End";

                SqlParameter sp_i_qsijobkey = new SqlParameter("@i_qsijobkey", SqlDbType.Int);
                SqlParameter sp_i_aborted = new SqlParameter("@i_aborted", SqlDbType.Int);
                SqlParameter sp_i_nonstandard_msg = new SqlParameter("@i_nonstandard_msg", SqlDbType.VarChar);
                SqlParameter sp_i_total_records = new SqlParameter("@i_total_records", SqlDbType.Int);

                sp_i_qsijobkey.Value = qsijobkey;
                sp_i_aborted.Value = (result_code < 2) ? 1 : 0; // aborted param is 1=yes, 0=no
                if (result_msg == null || result_msg.Length == 0) // || result_code >= 0 to prevent duplicate entries on XVQ abort?
                    sp_i_nonstandard_msg.Value = DBNull.Value;  // use default "job completed" message
                else
                    sp_i_nonstandard_msg.Value = result_msg;    // this was returned by Process_File()
                sp_i_total_records.Value = record_count;

                cmd.Parameters.Clear();
                cmd.Parameters.Add(sp_i_qsijobkey);
                cmd.Parameters.Add(sp_i_userid);
                cmd.Parameters.Add(sp_i_aborted);
                cmd.Parameters.Add(sp_i_nonstandard_msg);
                cmd.Parameters.Add(sp_i_total_records);
                cmd.Parameters.Add(sp_o_error_code);
                cmd.Parameters.Add(sp_o_error_desc);

                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();

                if ((int)sp_o_error_code.Value < 0)
                {
                    // @o_error_code signifying job not running, or
                    // dbo.write_qsijobmessage unable to read/write/access the qsijobmessages tables.

                    Msg_Writer(1, "Error registering QsiJob end - " + sp_o_error_desc.Value.ToString());
                }
                else
                {
                    // No error registering QsiJob end, but o_error_desc should contain msg with job stats -> write to log file
                    result_msg = sp_o_error_desc.Value.ToString();
                    if (result_msg != null && result_msg.Length > 0)
                    {
                        Msg_Writer(1, result_msg);
                    }
                }
            }
            catch (Exception ex)
            {
                if (conn != null && conn.State != ConnectionState.Closed)
                    conn.Close();

                result_msg = "System error: " + ex.ToString();
                Msg_Writer(2, result_msg);
            }
        }

        private static int Process_File(string input_filename, int qsijobkey, out int result_code, out string result_msg)
        {
            StreamReader SR = null;
            SqlConnection conn = null;
            int record_count = 0;

            result_code = 7;  // Assume success -> UpdFld_XXXX result code 7
            result_msg = null;

            try
            {
                SR = new StreamReader(input_filename, Encoding.Default);
                string S;

                // Set up for repeated calling of sproc within loop

                conn = new SqlConnection(interface_connect_str);
                SqlCommand cmd = new SqlCommand(interface_sproc_name, conn);
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter sp_i_qsijobkey = new SqlParameter("@qsijobkey", SqlDbType.Int);
                SqlParameter sp_i_inputrecord = new SqlParameter("@record_buffer", SqlDbType.VarChar);
                SqlParameter sp_o_result_code = new SqlParameter("@o_result_code", SqlDbType.Int);
                SqlParameter sp_o_result_desc = new SqlParameter("@o_result_desc", SqlDbType.VarChar);

                sp_i_qsijobkey.Value = qsijobkey;
                // sp_i_inputrecord.Value is assigned below in the while loop
                sp_o_result_desc.Value = DBNull.Value;  // set to null means no qsijob msg on success

                sp_o_result_code.Direction = ParameterDirection.Output;
                sp_o_result_desc.Direction = ParameterDirection.Output;

                sp_o_result_desc.Size = 2000;

                cmd.Parameters.Add(sp_i_qsijobkey);
                cmd.Parameters.Add(sp_i_inputrecord);
                cmd.Parameters.Add(sp_o_result_code);
                cmd.Parameters.Add(sp_o_result_desc);

                int subrec_nesting_level = 0;
                string subrec_accum = "";

                while ((S = SR.ReadLine()) != null || subrec_accum.Length > 0)
                {
                    if (S != null)
                    {
                        if (S.Trim() == "")
                            continue;

                        if (S.ToLower().Equals("[#begin_subrecord#]"))
                        {
                            // Don't include outer-most record delimiters between _whole_ records in stream
                            if (subrec_nesting_level > 0)
                                subrec_accum += (S + Environment.NewLine);  // include newline that StreamReader.ReadLine() stripped off

                            subrec_nesting_level++;
                        }
                        else if (S.ToLower().Equals("[#end_subrecord#]"))
                        {
                            subrec_nesting_level--;

                            // Don't include outer-most record delimiters between _whole_ records in stream
                            if (subrec_nesting_level > 0)
                                subrec_accum += (S + Environment.NewLine);  // include newline that StreamReader.ReadLine() stripped off
                        }
                        else
                        {
                            // Don't include outer-most record delimiters between _whole_ records in stream
                            subrec_accum += (S + Environment.NewLine);  // include newline that StreamReader.ReadLine() stripped off
                        }

                        // Accumulate any nested (one-to-many) levels and pass as single entity to interface
                        if (subrec_nesting_level > 0)
                            continue;
                    }

                    if (subrec_accum.Length > 0)
                    {
                        sp_i_inputrecord.Value = subrec_accum;  // other parameter settings don't change
                        subrec_accum = "";   // re-set
                    }
                    else
                        continue;  // empty record

                    // Process the record

                    record_count++;

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();
                    //cmd.Parameters.Clear();

                    // Check for fatal error

                    if ((int)sp_o_result_code.Value < 0 || (int)sp_o_result_code.Value == 1)
                    {
                        // Pass the error msg out to the calling routine for registering with job end
                        result_code = (int) sp_o_result_code.Value;
                        result_msg = sp_o_result_desc.Value.ToString();

                        break;  // abort the job
                    }
                }

                return record_count;
            }
            catch (Exception ex)
            {
                if (conn != null && conn.State != ConnectionState.Closed)
                    conn.Close();

                result_code = -1;
                result_msg = "System error: " + ex.ToString();
                /*
                Let Process_Job() do the error msg writing.  We don't have it also do the exception catch because
                we want it to register the qsijob end, and to log the job stats even in event of job abort error.
                */

                return record_count;
            }
            finally
            {
                if (SR != null)
                    SR.Close();
            }
        }

        private static string TimeStamp_Formatted()
        {
            DateTime dt = DateTime.Today; // .Now;  // fetch the system time just once and re-use it

            //string dtstamp = DateTime.Today.ToShortDateString();
            string s_day    = dt.Day.ToString().Length == 1 ? "0" + dt.Day.ToString() : dt.Day.ToString();
            string s_month  = dt.Month.ToString().Length == 1 ? "0" + dt.Month.ToString() : dt.Month.ToString();
            string s_year   = dt.Year.ToString();
            string s_hour   = dt.Hour.ToString().Length == 1 ? "0" + dt.Hour.ToString() : dt.Hour.ToString();
            string s_minute = dt.Minute.ToString().Length == 1 ? "0" + dt.Minute.ToString() : dt.Minute.ToString();
            string s_second = dt.Second.ToString().Length == 1 ? "0" + dt.Second.ToString() : dt.Second.ToString();

            return s_year + s_month + s_day + s_hour + s_minute + s_second;
        }

        private static void Msg_Writer(int msg_type, string msg)
        {
            // Initialize if first time through
            if (log_pathname == null)
            {
                // If there is need to write to log before can read logfilelocation from config file,
                // then use local directory - usually this only happens due to an immediate fatal error
                // and there won't be any more logging after that message.

                if (logfilelocation == null || logfilelocation.Length == 0)
                    logfilelocation = ".";
                else if (!Directory.Exists(logfilelocation))
                {
                    Directory.CreateDirectory(logfilelocation);  // create log directory if it doesn't exist

                    if (!Directory.Exists(logfilelocation))
                        logfilelocation = ".";  // was bad spec from config file
                }

                log_pathname = Path.GetFullPath(logfilelocation) + "\\" + "Log_" + dtstamp + ".txt";

                if (tw == null)
                    tw = new StreamWriter(log_pathname, true);
            }

            // Format the message
            if (msg_type == 0)
            {
                if (msg == "divider-")
                    msg = "".PadRight(80, '-');
            }
            else
            {
                string prefix = DateTime.Now.ToString() + " - ";

                if (msg_type == 2)
                    prefix += "Error - ";

                msg = prefix + msg;
            }

            Console.WriteLine(msg);
            if (tw != null)
                tw.WriteLine(msg);
        }


        private static string Get_ConfigFile_Parameters(string interface_id)
        {
            string section_name = interface_id + ".appSettings";
            string error_msg = "";
            
            NameValueCollection settings = (NameValueCollection)System.Configuration.ConfigurationManager.GetSection(section_name);

            if (settings["TMMdbConnection"] == null
                || (interface_connect_str = settings["TMMdbConnection"].ToString()).Length == 0)
                error_msg += (((error_msg.Length > 0) ? "   " : "") + "Configuration file is missing the TMM database connection string" + Environment.NewLine);

            if (settings["interface_sproc_name"] == null
                || (interface_sproc_name = settings["interface_sproc_name"].ToString()).Length == 0)
                error_msg += (((error_msg.Length > 0) ? "   " : "") + "Configuration file is missing the interface's stored procedure name" + Environment.NewLine);

            if (settings["source_type"] == null
                || (source_type = settings["source_type"].ToString().ToLower()).Length == 0)
                error_msg += (((error_msg.Length > 0) ? "   " : "") + "Configuration file is missing the inbound data's source type" + Environment.NewLine);
            else if (source_type != "xml" &&
                source_type != "xmlflat" &&
                source_type != "seff" &&
                source_type != "sql" &&
                source_type != "table" &&
                source_type != "file")
                error_msg += (((error_msg.Length > 0) ? "   " : "") + "Inbound data's source type specified in configuration file is not a recognized type" + Environment.NewLine);

            if (settings["source"] == null
                || (source_spec = settings["source"].ToString()).Length == 0)
                error_msg += (((error_msg.Length > 0) ? "   " : "") + "Configuration file is missing the inbound data's source specification (e.g. the filename, tablename, sql expression, or other)" + Environment.NewLine);

            if (source_type != null)
            {
                if (source_type.StartsWith("xml"))
                {
                    if (settings["source_schema_if_xml"] == null
                        || (source_spec_part2 = settings["source_schema_if_xml"].ToString()).Length == 0)
                        error_msg += (((error_msg.Length > 0) ? "   " : "") + "Configuration file is missing the XML source's schema (.xsd) filename" + Environment.NewLine);
                }

                if (source_type == "table" || source_type == "seff" || source_type == "sql")
                {
                    if (settings["source_connection_if_db"] == null
                        || (source_connect_str = settings["source_connection_if_db"].ToString()).Length == 0)
                        error_msg += (((error_msg.Length > 0) ? "   " : "") + "Configuration file is missing the source's connection string" + Environment.NewLine);
                }
            }

            if (settings["logfilelocation"] == null
                || (logfilelocation = settings["logfilelocation"].ToString()).Length == 0)
                logfilelocation = ".";

            if (settings["tempfilelocation"] == null
                || (tempfilelocation = settings["tempfilelocation"].ToString()).Length == 0)
                tempfilelocation = ".";

            return error_msg;
        }
    }
}
