-------------------------------------------------------------------------------
--                                                                           --
--                   Copyright (C) 2010-, Thomas Løcke                   --
--                                                                           --
--  This library is free software;  you can redistribute it and/or modify    --
--  it under terms of the  GNU General Public License  as published by the   --
--  Free Software  Foundation;  either version 3,  or (at your  option) any  --
--  later version. This library is distributed in the hope that it will be   --
--  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     --
--                                                                           --
--  As a special exception under Section 7 of GPL version 3, you are         --
--  granted additional permissions described in the GCC Runtime Library      --
--  Exception, version 3.1, as published by the Free Software Foundation.    --
--                                                                           --
--  You should have received a copy of the GNU General Public License and    --
--  a copy of the GCC Runtime Library Exception along with this program;     --
--  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
--  <http://www.gnu.org/licenses/>.                                          --
--                                                                           --
-------------------------------------------------------------------------------

with GNATCOLL.Traces.Syslog;
with Yolk.Configuration;

package body Yolk.Log is

   AWS_Access : GNATCOLL.Traces.Trace_Handle;
   AWS_Error  : GNATCOLL.Traces.Trace_Handle;

   Handle_Array : array (Trace_Handles) of GNATCOLL.Traces.Trace_Handle;

   procedure Initialize;
   --  Setup and activate the available trace handles.

   -----------------------------
   --  AWS_Access_Log_Writer  --
   -----------------------------

   procedure AWS_Access_Log_Writer
     (Message : in String)
   is
   begin
      GNATCOLL.Traces.Trace (Handle  => AWS_Access,
                             Message => Message);
   end AWS_Access_Log_Writer;

   ----------------------------
   --  AWS_Error_Log_Writer  --
   ----------------------------

   procedure AWS_Error_Log_Writer
     (Message : in String)
   is
   begin
      GNATCOLL.Traces.Trace (Handle  => AWS_Error,
                             Message => Message);
   end AWS_Error_Log_Writer;

   ------------------
   --  Initialize  --
   ------------------

   procedure Initialize
   is
      use Yolk.Configuration;
   begin
      GNATCOLL.Traces.Syslog.Register_Syslog_Stream;

      --  Alert log
      Handle_Array (Alert) := GNATCOLL.Traces.Create
        (Unit_Name => "ALERT",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Alert_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Alert),
         Active => Config.Get (Alert_Log_Activate));

      --  AWS access log
      AWS_Access := GNATCOLL.Traces.Create
        (Unit_Name => "AWS_ACCESS",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (AWS_Access_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => AWS_Access,
         Active => Config.Get (AWS_Access_Log_Activate));

      --  AWS error log
      AWS_Error := GNATCOLL.Traces.Create
        (Unit_Name => "AWS_ERROR",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (AWS_Error_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => AWS_Error,
         Active => Config.Get (AWS_Error_Log_Activate));

      --  Critical log
      Handle_Array (Critical) := GNATCOLL.Traces.Create
        (Unit_Name => "CRITICAL",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Critical_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Critical),
         Active => Config.Get (Critical_Log_Activate));

      --  Debug log
      Handle_Array (Debug) := GNATCOLL.Traces.Create
        (Unit_Name => "DEBUG",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Debug_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Debug),
         Active => Config.Get (Debug_Log_Activate));

      --  Emergency log
      Handle_Array (Emergency) := GNATCOLL.Traces.Create
        (Unit_Name => "EMERGENCY",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Emergency_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Emergency),
         Active => Config.Get (Emergency_Log_Activate));

      --  Error log
      Handle_Array (Error) := GNATCOLL.Traces.Create
        (Unit_Name => "ERROR",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Error_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Error),
         Active => Config.Get (Error_Log_Activate));

      --  Info log
      Handle_Array (Info) := GNATCOLL.Traces.Create
        (Unit_Name => "INFO",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Info_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Info),
         Active => Config.Get (Info_Log_Activate));

      --  Notice log
      Handle_Array (Notice) := GNATCOLL.Traces.Create
        (Unit_Name => "NOTICE",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Notice_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Notice),
         Active => Config.Get (Notice_Log_Activate));

      --  SQL log
      Handle_Array (SQL) := GNATCOLL.Traces.Create
        (Unit_Name => "SQL",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (SQL_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (SQL),
         Active => Config.Get (SQL_Log_Activate));

      --  SQL cache log
      Handle_Array (SQL_Cache) := GNATCOLL.Traces.Create
        (Unit_Name => "SQL.CACHE",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (SQL_Cache_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (SQL_Cache),
         Active => Config.Get (SQL_Cache_Log_Activate));

      --  SQL error log
      Handle_Array (SQL_Error) := GNATCOLL.Traces.Create
        (Unit_Name => "SQL.ERROR",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (SQL_Error_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (SQL_Error),
         Active => Config.Get (SQL_Error_Log_Activate));

      --  SQL select log
      Handle_Array (SQL_Select) := GNATCOLL.Traces.Create
        (Unit_Name => "SQL.SELECT",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (SQL_Select_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (SQL_Select),
         Active => Config.Get (SQL_Select_Log_Activate));

      --  Warning log
      Handle_Array (Warning) := GNATCOLL.Traces.Create
        (Unit_Name => "WARNING",
         Default   => GNATCOLL.Traces.On,
         Stream    =>
           "&syslog:" & Config.Get (Warning_Syslog_Facility_Level));

      GNATCOLL.Traces.Set_Active
        (Handle => Handle_Array (Warning),
         Active => Config.Get (Warning_Log_Activate));
   end Initialize;

   -------------
   --  Trace  --
   -------------

   procedure Trace
     (Handle  : in Trace_Handles;
      Message : in String)
   is
   begin
      GNATCOLL.Traces.Trace (Handle  => Handle_Array (Handle),
                             Message => Message);
   end Trace;
begin
   Initialize;
end Yolk.Log;
