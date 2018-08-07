<%@ Register TagPrefix="web" Namespace="QSolution.Web" Assembly="Web" %>
<%@ Register TagPrefix="Page" TagName="Home" Src="~/PageControls/Reports/Reports.ascx" %>
<%@ Register TagPrefix="qswc" Namespace="QSolution.Web.WebControls" Assembly="WebControls" %>
<%@ page language="c#" inherits="QSolution.WebTitleManagement.Reports.Reports, App_Web_reports.aspx.dfa151d5" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<HTML>
  <HEAD>
    <title>
      <asp:Literal id="PageTitleLiteral" runat="server">TBD</asp:Literal></title>
    <meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR">
    <meta content="C#" name="CODE_LANGUAGE">
    <meta content="JavaScript" name="vs_defaultClientScript">
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
    <asp:Literal id="HeaderAdditionsLiteral" runat="server"></asp:Literal>
  </HEAD>
  <body bottomMargin="0" leftMargin="0" topMargin="0" rightMargin="0">
    <form id="Form1" method="post" runat="server">
      <qswc:Lili2 id="Lili1" runat="server" />
      <web:templatewithsinglecontentcontrol id="Templatewithsinglecontentcontrol2" runat="server" template="~/Templates/TemplateL2Layout.ascx">
        <page:home id="Home1" runat="server"></page:home>
      </web:templatewithsinglecontentcontrol>
    </form>
  </body>
</HTML>
