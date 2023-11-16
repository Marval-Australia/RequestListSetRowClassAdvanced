<%@ WebHandler Language = "C#" Class="RequestListSetRowClassHandler" %>

using System;
using System.IO;
using System.Xml;
using System.Xml.Linq;
using System.Net;
using System.Linq;
using System.Web;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Xml.Serialization;
using Serilog;
using System.Web.Script.Serialization;
using System.Data.SqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using MarvalSoftware;
using MarvalSoftware.ServiceDesk.Facade;
using MarvalSoftware.UI.WebUI.ServiceDesk.RFP.Plugins;
using Microsoft.Win32;

/// <summary>
/// Request Dynamic Form Plugin Handler
/// </summary>
public class RequestListSetRowClassHandler : PluginHandler
{
    public override bool IsReusable { get { return false; } }
    private int requestID;
    private string RequestAttrID { get { return this.GlobalSettings["RequestAttributeID"]; } }
    private string DBConnectionStringFromConfig { get { return this.GlobalSettings["DBConnectionString"]; } }
    private string RequestAttributeValue { get { return this.GlobalSettings["RequestAttributeValue"]; } }
    private string RequestAttrValue { get { return this.GlobalSettings["RequestAttrValue"]; } }
    private string cssClassName { get { return this.GlobalSettings["cssClassName"]; } }

    public class MyObject
    {
        public List<object> ConfigParams { get; set; }
        public List<object> RequestParams { get; set; }
    }

    private string GetDBString()
    {
        string connectionString = "";
        string msmdLocation = GetAppPath("MSM");
        string path = msmdLocation;
        string newPath = Path.GetFullPath(Path.Combine(path, @"..\"));
        string openFilePath = newPath + "connectionStrings.config";
        XmlDocument xmlDoc = new XmlDocument();
        xmlDoc.Load(openFilePath);
        XmlNodeList nodeList = xmlDoc.SelectNodes("/appSettings/add[@key='DatabaseConnectionString']");
        if (nodeList.Count > 0)
        {
            connectionString = nodeList[0].Attributes["value"].Value;
        }
        else
        {
        }
        if (connectionString == "")
        {
            Log.Information("Could not find connection string on the local machine");
            return DBConnectionStringFromConfig;
        }
        else
        {
            return connectionString;
        }

    }

    private string GetAppPath(string productName)
    {
        const string foldersPath = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders";
        var baseKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64);

        var subKey = baseKey.OpenSubKey(foldersPath);
        if (subKey == null)
        {
            baseKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry32);
            subKey = baseKey.OpenSubKey(foldersPath);
        }
        return subKey != null ? subKey.GetValueNames().FirstOrDefault(kv => kv.Contains(productName)) : "ERROR";
    }

    private string GetRequestAttrValue(int requestId)
    {
        List<object> configParams = new List<object>();
        string DBConnectionString = GetDBString();
        configParams.Add(new { RequestAttrID = RequestAttrID, RequestAttributeValue = RequestAttributeValue });
        var connString = DBConnectionString;
        List<object> requestParams = new List<object>();
        using (SqlConnection conn = new SqlConnection(connString))
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandText = "dbo.requestAttrValue_findAllById";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@requestId", requestId);
                cmd.Connection = conn;
                conn.Open();
                using (SqlDataReader sdr = cmd.ExecuteReader())
                {
                    while (sdr.Read())
                    {
                       
                        requestParams.Add(new
                        {
                           
                            Name = sdr["name"],
                            booleanValue = sdr["booleanValue"],
                            numberValue = sdr["numberValue"],
                            dateValue = sdr["dateValue"],
                            textValue = sdr["textValue"],
                            requestAttributeTypeId = sdr["requestAttributeTypeId"]
                         
                        });
                    }
                }
                conn.Close();
            }
            MyObject myObject = new MyObject
            {
                ConfigParams = configParams,
                RequestParams = requestParams
            };
            return (new JavaScriptSerializer().Serialize(myObject));
        }
    }
    /// <summary>
    /// Main Request Handler
    /// </summary>
    public override void HandleRequest(HttpContext context)
    {
        var param = context.Request.HttpMethod;
        var getParamVal = context.Request.Params["settingToRetrieve"] ?? string.Empty;
        if (string.IsNullOrEmpty(getParamVal))
        {
            requestID = !string.IsNullOrWhiteSpace(context.Request.Params["requestID"]) ? int.Parse(context.Request.Params["requestID"]) : 0;
            if (requestID == 0)
            {
                Log.Information("No request ID passed, skipping routine");
            }
            else
            {
                // Log.Information("Request ID passed as " + requestID);
                string json = this.GetRequestAttrValue(requestID);
                context.Response.Write(json);
            }
        }
        else
        {
            switch (param)
            {
                case "GET":
                    if (getParamVal == "CSSAttribute")
                    {
                        context.Response.Write(this.GlobalSettings["cssClassName"]);
                    }
                    else if (getParamVal == "GetRequestAttributeValue")
                    {
                    }
                    else
                    {
                    }
                    break;
                case "POST":
                    break;
            }
        }
        // context.Response.Write(pluginConfig);
    }
}
